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

import SwiftyJSON


package protocol TypeMetadataClaimsValidatorType {
  func validate(
    _ payload: JSON,
    _ metadata: ResolvedTypeMetadata?
  ) throws
}

struct TypeMetadataClaimsValidator: TypeMetadataClaimsValidatorType {
  
  func validate(
    _ payload: JSON,
    _ metadata: ResolvedTypeMetadata?
  ) throws {

    guard let metadata = metadata else {
      throw TypeMetadataError.missingTypeMetadata
    }
    
    try validateVCT(payload["vct"].string, expectedVct: metadata.vct)
    
    let langs = metadata.displays.map { $0.lang }
    let uniqueLangs = Set(langs)
    guard langs.count == uniqueLangs.count else {
      throw TypeMetadataError.duplicateLanguageInDisplay
    }
  }
  
  private func validateVCT(
    _ payloadVct: String?,
    expectedVct: String
  ) throws {
    guard let vct = payloadVct, !vct.isEmpty else {
      throw TypeMetadataError.missingOrInvalidVCT
    }
    guard vct == expectedVct else {
      throw TypeMetadataError.vctMismatch
    }
  }
}
