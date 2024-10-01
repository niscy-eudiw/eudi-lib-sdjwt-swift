/*
 * Copyright (c) 2023 European Commission
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import Foundation
import X509
import JSONWebKey
import SwiftyJSON
import JSONWebSignature
import JSONWebToken

private let HTTPS_URI_SCHEME = "https"
private let DID_URI_SCHEME = "did"
private let SD_JWT_VC_TYPE = "vc+sd-jwt"

/**
 * A protocol to look up public keys from DIDs/DID URLs.
 */
public protocol LookupPublicKeysFromDIDDocument {
  func lookup(did: String, didUrl: String?) async -> [JWK]?
}

protocol SdJwtVcVerifierType {
  func verifyIssuance(
    unverifiedSdJwt: String
  ) async throws -> Result<SignedSDJWT, any Error>
  func verifyIssuance(
    unverifiedSdJwt: JSON
  ) async throws -> Result<SignedSDJWT, any Error>
}

public class SDJWTVCVerifier: SdJwtVcVerifierType {
  
  private let trust: X509CertificateTrust
  private let lookup: LookupPublicKeysFromDIDDocument?
  private let fetcher: any SdJwtVcIssuerMetaDataFetching
  
  public init(
    fetcher: SdJwtVcIssuerMetaDataFetching = SdJwtVcIssuerMetaDataFetcher(
      urlSession: .shared
    ),
    trust: X509CertificateTrust = X509CertificateTrustFactory.none,
    lookup: LookupPublicKeysFromDIDDocument? = nil
  ) {
    self.fetcher = fetcher
    self.trust = trust
    self.lookup = lookup
  }
  
  func verifyIssuance(
    unverifiedSdJwt: String
  ) async throws -> Result<SignedSDJWT, any Error> {
    let parser = CompactParser(serialisedString: unverifiedSdJwt)
    let jws = try parser.getSignedSdJwt().jwt
    let jwk = try await issuerJwsKeySelector(
      jws: jws,
      trust: trust,
      lookup: lookup
    )
    
    switch jwk {
    case .success(let jwk):
      return try SDJWTVerifier(
        parser: CompactParser(
          serialisedString: unverifiedSdJwt
        )
      ).verifyIssuance { jws in
        try SignatureVerifier(
          signedJWT: jws,
          publicKey: jwk
        )
      }
    case .failure(let error):
      throw error
    }
  }
  
  func verifyIssuance(
    unverifiedSdJwt: JSON
  ) async throws -> Result<SignedSDJWT, any Error> {
    
    guard
      let sdJwt = try SignedSDJWT(
        json: unverifiedSdJwt
      )
    else {
      throw SDJWTVerifierError.invalidJwt
    }
    
    let jws = sdJwt.jwt
    let jwk = try await issuerJwsKeySelector(
      jws: jws,
      trust: trust,
      lookup: lookup
    )
    
    switch jwk {
    case .success(let jwk):
      return try SDJWTVerifier(
        sdJwt: sdJwt
      ).verifyIssuance { jws in
        try SignatureVerifier(
          signedJWT: jws,
          publicKey: jwk
        )
      }
    case .failure(let error):
      throw error
    }
  }
}

private extension SDJWTVCVerifier {
  func issuerJwsKeySelector(
    jws: JWS,
    trust: X509CertificateTrust,
    lookup: LookupPublicKeysFromDIDDocument?
  ) async throws -> Result<JWK, any Error> {
    
    guard jws.protectedHeader.algorithm != nil else {
      throw SDJWTVerifierError.noAlgorithmProvided
    }
    
    guard let source = try keySource(jws: jws) else {
      return .failure(SDJWTVerifierError.invalidJwt)
    }
    
    switch source {
    case .metadata(let iss, let kid):
      guard let jwk = try await fetcher.fetchIssuerMetaData(
        issuer: iss
      )?.jwks.first(where: { $0.keyID == kid }) else {
        return .failure(SDJWTVerifierError.invalidJwt)
      }
      return .success(jwk)
      
    case .x509CertChain(_, let chain):
      if await trust.isTrusted(chain: chain) {
        guard let jwk = try chain
          .first?
          .publicKey
          .serializeAsPEM()
          .pemString
          .pemToSecKey()?
          .jwk else {
          return .failure(SDJWTVerifierError.invalidJwt)
        }
        return .success(jwk)
      }
      return .failure(SDJWTVerifierError.invalidJwt)
    case .didUrl(let iss, let kid):
      guard let key = await lookup?.lookup(
        did: iss,
        didUrl: kid
      )?.first(where: { $0.keyID == kid }) else {
        return .failure(SDJWTVerifierError.invalidJwt)
      }
      return .success(key)
    }
  }
  
  func keySource(jws: JWS) throws -> SdJwtVcIssuerPublicKeySource? {
    
    guard let iss = try? jws.iss() else {
      throw SDJWTVerifierError.invalidIssuer
    }
    
    let certChain = parseCertificates(from: jws.protectedHeaderData)
    let leaf = certChain.first
    
    let issUrl = URL(string: iss)
    let issScheme = issUrl?.scheme
    
    if issScheme == HTTPS_URI_SCHEME && certChain.isEmpty {
      guard let issUrl = issUrl else {
        return nil
      }
      return .metadata(
        iss: issUrl,
        kid: jws.protectedHeader.keyID
      )
    } else if issScheme == HTTPS_URI_SCHEME {
      guard
        let issUrl = issUrl,
        isIssuerFQDNContained(in: leaf, issuerUrl: issUrl) || isIssuerURIContained(in: leaf, iss: iss)
      else {
        return nil
      }
      
      return .x509CertChain(
        iss: issUrl,
        chain: certChain
      )
    } else if issScheme == DID_URI_SCHEME && certChain.isEmpty {
      return .didUrl(
        iss: iss,
        kid: jws.protectedHeader.keyID
      )
    }
    return nil
  }
  
  private func isIssuerFQDNContained(in leaf: Certificate?, issuerUrl: URL) -> Bool {
    // Get the host from the issuer URL
    guard let issuerFQDN = issuerUrl.host else {
      return false
    }
    
    // Extract the DNS names from the certificate's subject alternative names
    let dnsNames = try? leaf?.extensions
      .subjectAlternativeNames?
      .rawSubjectAlternativeNames()
    
    // Check if any of the DNS names match the issuer FQDN
    let contains = dnsNames?.contains(where: { $0 == issuerFQDN }) ?? false
    
    return contains
  }
  
  func isIssuerURIContained(in leaf: Certificate?, iss: String) -> Bool {
    // Extract the URIs from the certificate's subject alternative names
    let uris = try? leaf?
      .extensions
      .subjectAlternativeNames?
      .rawUniformResourceIdentifiers()
    
    // Check if any of the URIs match the 'iss' string
    let contains = uris?.contains(where: { $0 == iss }) ?? false
    
    return contains
  }
}
