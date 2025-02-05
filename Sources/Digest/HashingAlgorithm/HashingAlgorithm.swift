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

public typealias Disclosure = String
public typealias DisclosureDigest = String

public protocol HashingAlgorithm {
  var identifier: String { get }

  func hash(disclosure: Disclosure) -> Data?
}

public enum HashingAlgorithmIdentifier: String, CaseIterable {
  case SHA256 = "sha-256"
  case SHA3256 = "sha3-256"
  case SHA384 = "sha-384"
  case SHA512 = "sha-512"

  public func hashingAlgorithm() -> HashingAlgorithm {

    switch self {
    case .SHA3256:
      return SHA3256Hashing()
    case .SHA256:
      return SHA256Hashing()
    case .SHA384:
      return SHA384Hashing()
    case .SHA512:
      return SHA512Hashing()
    }
  }
}
