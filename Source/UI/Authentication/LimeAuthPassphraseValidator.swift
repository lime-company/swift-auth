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

/// Result of the PIN/password strength measurement
public enum LimeAuthPassphraseResult {
    /// Strength is OK
    case ok
    /// Warning should be displayed with provided strings (defualt will be used in case of nil)
    case warning(_ localized: LimeAuthPassphraseResultStrings?)
}

/// Strings for "Weak Passphrase Alert"
public struct LimeAuthPassphraseResultStrings {
    public let title: String
    public let text: String
    public let continueAnywayButton: String
    public let differentPassphraseButton: String
    
    public init(title: String, text: String, continueAnywayButton: String, differentPassphraseButton: String) {
        self.title = title
        self.text = text
        self.continueAnywayButton = continueAnywayButton
        self.differentPassphraseButton = differentPassphraseButton
    }
}

/// Types of passphrase
public enum LimeAuthPassphraseType {
    /// PIN - numbers only
    case pin
    /// Common password
    case password
}

public protocol LimeAuthPassphraseValidatorProvider {
    func createValidator() -> LimeAuthPassphraseValidator
}

/// Service that will decide, if warning should be displayed
/// if users try to set weak PIN or password
public protocol LimeAuthPassphraseValidator {
    
    /// Validates strength of the password
    ///
    /// - Parameters:
    ///   - passphrase: string with passphrase
    ///   - type: type of passphrase
    /// - Returns: strength of the passphrase
    func validate(_ passphrase: String, type: LimeAuthPassphraseType) -> LimeAuthPassphraseResult
}
