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
import SwiftyJSON

typealias ClaimSet = (value: JSON, disclosures: [Disclosure])

/// A factory class responsible for creating and encoding SDJWT objects.
/// Creates a valid JWT JSON along with its disclosures
class SDJWTFactory {

  // MARK: - Properties

  let digestCreator: DigestCreator
  let saltProvider: SaltProvider
  let decoysLimit: Int

  var decoyCounter = 0
  // MARK: - LifeCycle

  /// Initialises an instance of `SDJWTFactory`.
  ///
  /// - Parameters:
  ///   - saltProvider: An instance of `SaltProvider` for obtaining salt strings.
  ///   - digestCreator: An instance of `DigestCreator` for creating digests and hashes.
  ///   - decoysLimit: If decoys are requesed, defaults to 0
  init(digestCreator: DigestCreator = DigestCreator(), saltProvider: SaltProvider, decoysLimit: Int = 0) {
    self.digestCreator = digestCreator
    self.saltProvider = saltProvider
    self.decoysLimit = decoysLimit
  }

  // MARK: - Methods - Public

  func createJWT(sdjwtObject: [String: SdElement]?) -> Result<ClaimSet, Error> {
    do {
      self.decoyCounter = 0
      return .success(try self.encodeObject(sdjwtObject: addSdAlgClaim(object: sdjwtObject)))
    } catch {
      return .failure(error)
    }
  }

  // MARK: - Methods - Private

  /// Encodes an SDJWT object into a ClaimSet containing JSON and disclosure information.
  ///
  /// - Parameters:
  ///   - sdjwtObject: The SDJWT object to be encoded.
  /// - Returns: A ClaimSet containing the encoded JSON and an array of Disclosures.
  /// - Throws: An error of type SDJWTError if the input object is not in the expected format.
  ///
  private func encodeObject(sdjwtObject: [String: SdElement]?) throws -> ClaimSet {
    // Check if the input object is of correct format
    guard let sdjwtObject else {
      throw SDJWTError.nonObjectFormat(ofElement: sdjwtObject)
    }

    // Initialize arrays to store disclosures and JSON output
    var outputDisclosures: [Disclosure] = []
    var outputJson = JSON()

    try sdjwtObject.forEach { claimKey, claimValue in
      let (json, disclosures) = try self.encodeClaim(key: claimKey, value: claimValue)
      outputDisclosures.append(contentsOf: disclosures)

      // Update output JSON based on claim value type
      switch claimValue {
      case .flat, .recursiveArray, .recursiveObject:
        outputJson[Keys.sd] = JSON(outputJson[Keys.sd].arrayValue + json[Keys.sd].arrayValue)
      default:
        outputJson[claimKey] = json
      }
    }

    // Return the encoded JSON and disclosures as a ClaimSet
    return (outputJson, outputDisclosures)
  }

  /// Encodes a single SDJWT claim value into a ClaimSet containing encoded JSON and associated disclosures.
  ///
  /// - Parameters:
  ///   - key: The key corresponding to the claim value being encoded.
  ///   - value: The SDJWT claim value to be encoded.
  /// - Returns: A ClaimSet containing the encoded JSON and an array of associated Disclosures.
  /// - Throws: An error if the encoding process encounters an issue.
  ///
  private func encodeClaim(key: String, value: SdElement) throws -> ClaimSet {
    switch value {
    case .plain(let plain):
      // For plain values, return the value itself along with an empty array of disclosures.
      return (plain, [])
      // ...........
    case .flat(let json):
      // Encode a primitive JSON claim value and disclose it.
      let (disclosure, digest) = try self.flatDisclose(key: key, value: json)
      // Add Decoys if needed
      let decoys = self.addDecoy()
      let output: JSON = [Keys.sd.rawValue: ([digest] + decoys).sorted()]
      return(output, [disclosure])
      // ...........
    case .object(let object):
      // Encode an object claim value by recursively encoding the SDJWT object.
      return try self.encodeObject(sdjwtObject: object)
      // ...........
    case .array(let array):
      // Encode an array claim value, disclosing each element and adding decoys.
      var disclosures: [Disclosure] = []
      let output = try array.reduce(into: JSON([Disclosure]())) { partialResult, element in
        switch element {
        case .plain(let json):
          partialResult.arrayObject?.append(json)
        default:
          let (disclosure, digest) = try self.discloseArrayElement(value: element.asJSON)
          let decoys = self.addDecoy()
            .sorted()
            .map {JSON([Keys.dots: $0])}
          let dottedKeyJson: JSON = [Keys.dots.rawValue: digest]
          partialResult.arrayObject?.append(dottedKeyJson)
          partialResult.arrayObject?.append(contentsOf: decoys)
          disclosures.append(disclosure)
        }
      }

      return (output, disclosures)
      // ...........
    case .recursiveObject(let object):
      // Encode a recursive object claim value by first encoding the nested object,
      // then encoding it as a flat value and returning the combined disclosures.
      let encodedObject = try self.encodeObject(sdjwtObject: object)
      let sdElement = try self.encodeClaim(key: key, value: .flat(encodedObject.value))
      return (sdElement.value, encodedObject.disclosures + sdElement.disclosures)
      // ...........
    case .recursiveArray(let array):
      // Encode a recursive array claim value by first encoding the nested array,
      // then encoding it as a flat value and returning the combined disclosures.
      let encodedArray = try self.encodeClaim(key: key, value: .array(array))
      let sdElement = try self.encodeClaim(key: key, value: .flat(encodedArray.value))
      return (sdElement.value, encodedArray.disclosures + sdElement.disclosures)
      // ...........
    }
  }

  /// Generates a disclosure and its corresponding digest by flat-disclosing the provided key-value pair.
  ///
  /// - Parameters:
  ///   - key: The key corresponding to the value being disclosed.
  ///   - value: The JSON value to be disclosed.
  /// - Returns: A tuple containing the Base64URLEncoded disclosure and its digest.
  /// - Throws: An error if an issue occurs during encoding, URL encoding, or hashing.
  ///       salt                      key                value
  ///   ["6qMQvRL5haj", "family_name", "Möbius"]
  private func flatDisclose(key: String, value: JSON) throws -> (Disclosure, DisclosureDigest) {
    let saltString = saltProvider.saltString
    let jsonArray = JSON(arrayLiteral: saltString, key, value)
    let stringToEncode = jsonArray.rawString(options: .withoutEscapingSlashes)
    // TODO: Remove before flight
    //      .replacingOccurrences(of: ",", with: ", ")
    guard let urlEncoded = stringToEncode?.toBase64URLEncoded(),
          let digest = digestCreator.hashAndBase64Encode(input: urlEncoded) else {
      throw SDJWTError.encodingError
    }

    return (urlEncoded, digest)
  }

  /// Generates a disclosure and its corresponding digest by flat-disclosing the provided key-value pair.
  ///
  /// - Parameters:
  ///   - value: The JSON value of the array element to be disclosed
  /// - Returns: A tuple containing the Base64URLEncoded disclosure and its digest.
  /// - Throws: An error if an issue occurs during encoding, URL encoding, or hashing.
  ///       salt                    value
  ///   ["6qMQvRL5haj",  "Möbius"]
  ///
  private func discloseArrayElement(value: JSON) throws -> (Disclosure, DisclosureDigest) {
    let saltString = saltProvider.saltString
    let jsonArray = JSON(arrayLiteral: saltString, value)
    let stringToEncode = jsonArray.rawString(options: .withoutEscapingSlashes)
    // TODO: Remove before flight
    //      .replacingOccurrences(of: ",", with: ", ")
    guard
      let urlEncoded = stringToEncode?.toBase64URLEncoded(),
      let digest = digestCreator.hashAndBase64Encode(input: urlEncoded)
    else {
      throw SDJWTError.encodingError
    }

    return (urlEncoded, digest)
  }

  // MARK: - Methods - Helpers

  private func addDecoy() -> [DisclosureDigest] {
    if decoyCounter < decoysLimit {
      let rand = Array(repeating: "", count: .random(in: 0...decoysLimit-decoyCounter))
        .compactMap {_ in digestCreator.decoy()}

      decoyCounter += rand.count
      return rand
    }
    return []
  }

  private func addSdAlgClaim(object: [String: SdElement]?) -> [String: SdElement]? {
    var object = object
    object?[Keys.sdAlg.rawValue] = SdElement.plain(value: digestCreator.hashingAlgorithm.identifier)
    return object
  }
}
