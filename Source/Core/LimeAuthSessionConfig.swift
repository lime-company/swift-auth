//
// Copyright 2018 Lime - HighTech Solutions s.r.o.
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
import LimeCore
import PowerAuth2
import Dispatch

public protocol LimeAuthSessionConfig: ImmutableConfig {
    
    // MARK: - PowerAuth related
    
    var powerAuth: PowerAuthConfiguration { get }
    var powerAuthKeychain: PA2KeychainConfiguration { get }
    var powerAuthHttpClient: PA2ClientConfiguration { get }
    
    // MARK: - Internal networking
    var operationDispatchQueue: DispatchQueue? { get }
    var operationCompletionQueue: DispatchQueue { get }
    
    // MARK: - Other settings
    
    /// When `AuthSession` detects that activation was removed on the server (during status fetch), it will
    /// automatically remove local activation (when set to true).
    ///
    /// If you want to handle this case by yourself, set this value to `false`
    /// and then use `LimeAuthSession.removeActivationLocal` method later on.
    var removeLocalActivationWhenRemovedOnServer: Bool { get }
}


public class MutableLimeAuthSessionConfig: LimeAuthSessionConfig, MutableConfig {
    
    public var powerAuth: PowerAuthConfiguration
    public var powerAuthKeychain: PA2KeychainConfiguration
    public var powerAuthHttpClient: PA2ClientConfiguration
    
    // dispatch queue
    public var operationDispatchQueue: DispatchQueue?
    public var operationCompletionQueue: DispatchQueue = .main
    
    public var removeLocalActivationWhenRemovedOnServer = true

    public init(powerAuth: PowerAuthConfiguration = PowerAuthConfiguration(),
                keychain: PA2KeychainConfiguration = .sharedInstance(),
                httpClient: PA2ClientConfiguration = .sharedInstance()) {
        self.powerAuth = powerAuth
        self.powerAuthKeychain = keychain
        self.powerAuthHttpClient = httpClient
    }
    
    public func makeImmutable() -> ImmutableConfig {
        return self as LimeAuthSessionConfig
    }
}
