//
// Copyright 2018 Wultra s.r.o.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions
// and limitations under the License.
//

import Foundation

/// The `LimeAuthRestApiError` structure represents an error object
/// returned from server, using PowerAuth for authentication.
///
/// You can construct this object and set it to LimeAuthError, if it's important
/// to handle returned error code after the authentication fails.
/// The structure is currently not used in the LimeAuth internals.
public struct LimeAuthRestApiError: Codable {
    
    public let code: String
    public let message: String
    
    public init(code: String, message: String) {
        self.code = code
        self.message = message
    }
}
