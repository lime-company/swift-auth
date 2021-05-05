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
import PowerAuth2

/// The `LimeAuthCredentialsProvider` protocol defines interface for getting and changing
/// credentials configuration in the application.
public protocol LimeAuthCredentialsProvider: class {
    
    /// Implementation must return configuration for currently applied credentials.
    var credentials: LimeAuthCredentials { get }
    
    /// Factory for object that will decide when to show warning when PIN or password is
    /// too weak during it's creation. This feature will be turned off if nil.
    var passphraseValidatorProvider: LimeAuthPassphraseValidatorProvider? { get }
    
    /// Implementation must change complexity of password. The complexity is represented
    /// by the index to the credential's passwordOptions array. In other words, function
    /// must effectively change type of password, used in the application.
    ///
    /// - parameter passwordIndex: index to credential's `passwordOptions` array
    /// - returns: false when provided index is out of bounds.
    func changePasswordComplexity(passwordIndex: Int) -> Bool
}

/// The `LimeAuthCredentialsStore` class implements persistent storage for LimeAuthCredentials configuration.
/// The class also conforms to `LimeAuthCredentialsProvider` protocol, so you can use it as credentials
/// provider to appropriate LimeAuth objects.
/// ## Data persistence
/// The class is persisting only value for `passwordIndex`, so you should take a special care about
/// how you change `passwordOptions` array in LimeAuthCredentials structure.
///
/// The `PowerAuthKeychain` is used as an underlying configuration storage, so it's recommended to reset the keychain
/// once you detect that application has been reinstalled.
public class LimeAuthCredentialsStore: LimeAuthCredentialsProvider {
    
    /// Name of default keychan service used for store information about password complexity.
    public static let defaultKeychainServiceName = "io.getlime.lib.LimeAuthUI"
    
    /// Key to underlying keychain service for store information about password complexity.
    public static let keyForPasswordIndex = "passwordIndex"
    
    public init(credentials: LimeAuthCredentials, keychain: PowerAuthKeychain? = nil, validatorProvider: LimeAuthPassphraseValidatorProvider? = nil) {
        self.credentials = credentials
        self.passphraseValidatorProvider = validatorProvider
        self.keychain = keychain ?? PowerAuthKeychain(identifier: LimeAuthCredentialsStore.defaultKeychainServiceName)
        if let restoredIndex = restoreIndex() {
            if isValid(passwordIndex: restoredIndex) {
                self.credentials.passwordIndex = restoredIndex
            } else {
                // This is bad, you have changed significantly `LimeAuthCredentials` structure, so it's not possible
                // to map previously used index to a new content of structure. The user will not be able to authenticate
                // with knowledge factor.
                D.error("LimeAuthSharedCredentials: Restored passwordIndex \(restoredIndex) is out of bounds <0, \(credentials.passwordOptions.count)")
            }
        }
    }
    
    /// Contains current credentials, valid for the application.
    public private(set) var credentials: LimeAuthCredentials
    
    /// Contains `PA2Keychain` instance associated to this object.
    public let keychain: PowerAuthKeychain
    
    /// Factory class that will create PassphraseValidator
    public let passphraseValidatorProvider: LimeAuthPassphraseValidatorProvider?
    
    /// Changes password complexity. The complexity is represented by the index to the
    /// credential's passwordOptions array.
    public func changePasswordComplexity(passwordIndex: Int) -> Bool {
        guard isValid(passwordIndex: passwordIndex) else {
            D.error("LimeAuthSharedCredentials: passwordIndex \(passwordIndex) is out of bounds <0, \(credentials.passwordOptions.count)")
            return false
        }
        credentials.passwordIndex = passwordIndex
        store(passwordIndex: passwordIndex)
        return true
    }
    
    
    private func isValid(passwordIndex: Int) -> Bool {
        return passwordIndex >= 0 && passwordIndex < credentials.passwordOptions.count
    }
    
    private func store(passwordIndex: Int) {
        keychain.update(value: passwordIndex, for: LimeAuthCredentialsStore.keyForPasswordIndex)
    }
    
    private func restoreIndex() -> Int? {
        return keychain.value(for: LimeAuthCredentialsStore.keyForPasswordIndex)
    }
}
