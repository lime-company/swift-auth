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
import PowerAuth2
import LimeCore

public class LimeAuthSession {
    
    /// Instance of `PowerAuthSDK` object associated with this session.
    ///
    /// ## Warning
    /// You should not use `PowerAuthSDK.sharedInstance()` in the application's code.
    /// The shared instnace is not initialized in this library.
    public let powerAuth: PowerAuthSDK
    
    /// Configuration use for this session creation.
    public let configuration: LimeAuthSessionConfig
    
    /// Helper class wrapping getting activation status
    internal lazy var statusFetcher: ActivationStatusFetcher = { ActivationStatusFetcher(session: self) }()
    
    /// Queue for critial operations synchronization
    internal var serializedQueue: OperationQueue
    internal var concurrentQueue: OperationQueue
    internal var operationCompletionQueue: DispatchQueue
    
    public init(config: LimeAuthSessionConfig) {
        // Keep config
        configuration = config
        // PowerAuthSDK alraedy raises an exception when config is wrong,
        // so it's safe when we unwrap created instance
        powerAuth = PowerAuthSDK(config)!
        
        // Configure queues
        serializedQueue = OperationQueue()
        serializedQueue.maxConcurrentOperationCount = 1
        concurrentQueue = OperationQueue()
        concurrentQueue.maxConcurrentOperationCount = 10
        // let assign dispatch queue
        let dispatchQueue = config.operationDispatchQueue ?? .global(qos: .userInitiated)
        serializedQueue.underlyingQueue = dispatchQueue
        concurrentQueue.underlyingQueue = dispatchQueue
        operationCompletionQueue = config.operationCompletionQueue

    }
    
}


// MARK: - Activation state checks -

public extension LimeAuthSession {
    
    public var canStartActivation: Bool {
        return powerAuth.canStartActivation()
    }
    
    public var hasPendingActivation: Bool {
        return powerAuth.hasPendingActivation()
    }
    
    public var hasValidActivation: Bool {
        return powerAuth.hasValidActivation()
    }
    
    public var activationIdentifier: String? {
        return powerAuth.activationIdentifier
    }
    
    public var activationFingerprint: String? {
        return powerAuth.activationFingerprint
    }
}


// MARK: - Debug

#if DEBUG
extension LimeAuthSession: CustomDebugStringConvertible {
    public var debugDescription: String {
        if self.canStartActivation {
            return "LimeAuthSession: EMPTY (can start activation)"
        } else if self.hasPendingActivation {
            return "LimeAuthSession: PENDING_ACTIVATION"
        } else if !self.hasValidActivation {
            if !self.powerAuth.session.hasValidSetup {
                return "LimeAuthSession: INVALID_SETUP"
            } else {
                return "LimeAuthSession: UNKNOWN_STATE"
            }
        }
        let status: String
        let aID = activationIdentifier ?? "(null)"
        if let fs = lastFetchedActivationStatus {
            switch fs.state {
            case .active: status = "ACTIVE, activationID: \(aID), attempts: \(fs.remainingAttempts)/\(fs.maxFailCount)"
            case .blocked: status = "BLOCKED, activationID: \(aID)"
            case .removed: status = "REMOVED, activationID: \(aID)"
            case .otp_Used: status = "OTP_USED"
            case .created: status = "CREATED"
            }
        } else {
            status = "NOT_FETCHED, activationID: \(aID)"
        }
        return "LimeAuthSession: VALID, status: \(status)"
    }
}
#endif

