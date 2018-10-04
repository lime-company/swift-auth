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

/// The LimeAuthCredentials structure contains a configuration for types of crendentials
/// used in the application.
public struct LimeAuthCredentials {
    
    /// The Password struct holds information about password complexity.
    public struct Password {
        /// Represents type of Password
        public enum PasswordType: Int {
            /// Fixed PIN. Number of digits is defined by `minimumLength`
            case fixedPin        = 0
            /// Variable length PIN. Number of digits is defined by `minimumLength` & `maximumLength`
            case variablePin     = 1
            /// Arbitrary password. Number of entered characters must be greater than `minimumLength`
            case password        = 2
        }
        /// Type of password
        public let type: PasswordType
        /// Minimum number of characters or digits
        public let minimumLength: Int
        /// Maximum number of digits (password type is not cropped)
        public let maximumLength: Int
        
        /// Designated initializer
        public init(_ type: PasswordType, min: Int, max: Int) {
            self.type = type
            self.minimumLength = min
            self.maximumLength = max
        }
    }
    
    /// Returns Password object for current configuration. The configuration is affected by `passwordIndex`
    public var password: Password {
        if passwordIndex >= 0 && passwordIndex < passwordOptions.count {
            return passwordOptions[passwordIndex]
        }
        // Return some invalid object
        D.error("LimeAuthCredentials config is not valid")
        return .fixedPin(length: 0)
    }
    
    /// Contains all available Password options for this application. Please read carefully discussion about
    /// `passwordOptionsOrder` property.
    public let passwordOptions: [Password]
    
    /// Contains indexes to `passwordOptions` for supported options for newly created passwords.
    ///
    /// # Discussion
    ///
    /// The combination of `passwordOptions` and `passwordIndex` determines an user's selected password complexity.
    /// This fact has a side effect, that you should not change the array of supported options between the application
    /// versions. You can add a new options at the end of the array, but you should never remove previously used option
    /// or change the order of options in the array. If you ignore this recommendation, then the user may not be able
    /// to authenticate with knowledge factor anymore.
    ///
    /// To solve compatibility between the application versions, you can prepare an array of indexes, which are currently
    /// supported in the current version of the application. The `passwordOptionsOrder` array allows you following tweaks:
    ///   - Deprecate a previously uset password configuration, by simply omit its index in the array
    ///   - Change visual order of the options
    public let passwordOptionsOrder: [Int]
    
    /// Index to `passwordOptions` array
    public var passwordIndex: Int
    
    /// The Biometry strcut holds information about usage of biometry authentication
    /// in the application.
    public struct Biometry {
        
        /// The Option enumeration defines modes of biometry authentication
        public enum Option {
            /// If set, then the appropriate biometry authentication is not allowed
            /// in the application at all.
            case disabled
            /// If set, then the biometry authentication is allowed and will be evaluated
            /// immediately. The password is then as a fallback.
            case enabledAndAutomatic
            /// If set, then the biometry authentication is allowed, but user needs to
            /// perform an action for its evaluation (e.g. tap on the button).
            /// In this mode, the pasword is a primary authentication and biometry is
            /// optional.
            case enabledOnDemand
        }
        
        /// Option for TouchID authentication
        public let touchId: Option
        
        /// Option for FaceID authentication
        public let faceId: Option
        
        public init(touchId: Option = .enabledAndAutomatic, faceId: Option = .enabledOnDemand) {
            self.touchId = touchId
            self.faceId = faceId
        }
    }
    
    public let biometry: Biometry
    
    
    /// Designated initializer
    ///
    /// - parameter passwordOptions: array of passphrase types, supported in the application
    /// - parameter passwordIndex: index to `passwordOptions` array. If you provide nil, then the first integer from `optionsOrder` will be used
    /// - parameter optionsOrder: contains indexes to `passwordOptions` array. If nil is provided, then whole range is internally constructed: `(0...passwordOptions.count-1)`
    /// - parameter biometry: Configuration for biometry factor. If nil is provided, then the default Biometry() structure is constructed.
    public init(passwordOptions: [Password], passwordIndex: Int? = nil, optionsOrder: [Int]? = nil, biometry: Biometry? = nil) {
        let order = optionsOrder ?? [Int](0...passwordOptions.count-1)
        let index = passwordIndex ?? order.first ?? -1
        if index < 0 || index >= passwordOptions.count {
            D.error("LimeAuthCredentials config contains invalid data")
        }
        self.biometry = biometry ?? Biometry()
        self.passwordOptions = passwordOptions
        self.passwordOptionsOrder = order
        self.passwordIndex = index
    }
}


public extension LimeAuthCredentials {
    
    /// Returns true if current user's complexity is no longer supported in the current application.
    /// The application's UI should display a warning about this situation and user should change
    /// his password to a new, supported one.
    public var isCurrentPasswordComplexityNoLongerSupported: Bool {
        return self.passwordOptionsOrder.index(of: self.passwordIndex) == nil
    }
    
    /// Constructs and returns default credentials object.
    public static func defaultCredentials() -> LimeAuthCredentials {
        let passwordOptions: [LimeAuthCredentials.Password] = [
            .fixedPin(length: 4),
            .fixedPin(length: 6),
            .variablePin(min: 6, max: 9),
            .alphanumeric(min: 6)
        ]
        return LimeAuthCredentials(passwordOptions: passwordOptions, passwordIndex: 0, optionsOrder: nil, biometry: nil)
    }
}

/// Extension for simple object creation
public extension LimeAuthCredentials.Password {
    
    /// Creates a password object for PIN with fixed length
    public static func fixedPin(length: Int) ->  LimeAuthCredentials.Password {
        return  LimeAuthCredentials.Password(.fixedPin, min: length, max: length)
    }
    
    /// Creates a password object for PIN with variable length
    public static func variablePin(min: Int, max: Int) ->  LimeAuthCredentials.Password {
        return  LimeAuthCredentials.Password(.variablePin, min: min, max: max)
    }
    
    /// Creates a password object for alphanumeric string with minimum length
    public static func alphanumeric(min: Int) ->  LimeAuthCredentials.Password {
        return  LimeAuthCredentials.Password(.password, min: min, max: 0)
    }
}


public extension LimeAuthCredentials.Biometry {
    
    /// Contains true whether biometry configuration matches actual support on the device.
    public var isSupportedOnDevice: Bool {
        var supported = PA2Keychain.supportedBiometricAuthentication
        if supported == .touchID && touchId == .disabled {
            supported = .none
        } else if supported == .faceID && faceId == .disabled {
            supported = .none
        }
        return supported != .none
    }

}


