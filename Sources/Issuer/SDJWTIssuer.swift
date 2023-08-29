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
import JOSESwift
import SwiftyJSON

class SDJWTIssuer {

  var claimSet: ClaimSet
  var kbJwt: KBJWT?

  let jwsController: JWSController

  enum Purpose {
    case issuance(ClaimSet)
    case presentation(ClaimSet, KBJWT?)
  }

//  let key = SecKey.representing(rsaPublicKeyComponents: RSAPublicKeyComponents)
//  let signer = Signer(signingAlgorithm: .ES256, key: .init(base64URLEncoded: ""))

  init(purpose: Purpose, jwsController: JWSController) {
    switch purpose {
    case .issuance(let claimSet):
      self.claimSet = claimSet
      self.kbJwt = nil
      // ..........
    case .presentation(let claimSet, let kbJwt):
      self.claimSet = claimSet
      self.kbJwt = kbJwt
      // ..........
    }

    self.jwsController = jwsController
  }

  func createSignedJWT() throws -> JWS {
    let header = JWSHeader(algorithm: jwsController.signatureAlgorithm)
    let payload = try Payload(claimSet.value.rawData())
    let signer = jwsController.signer

    guard let jws = try? JWS(header: header, payload: payload, signer: signer) else {
      throw SDJWTError.serializationError
    }

    return jws
  }

  func serialize(jws: JWS) -> Data? {
    let jwsString = jws.compactSerializedString
    let disclosures = claimSet.disclosures.reduce(into: "") { partialResult, disclosure in
      partialResult += "~\(disclosure)"
    }

    let kbJwtString = (try? self.kbJwt?.toJSONString() ?? "") ?? ""

    return (jwsString + disclosures + kbJwtString).data(using: .utf8)
  }
}

struct KBJWT: Codable {
  var nonce: String
  var aud: String
  var iat: Int
}
