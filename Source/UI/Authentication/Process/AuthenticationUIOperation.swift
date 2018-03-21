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

import UIKit
import PowerAuth2


public protocol AuthenticationUIOperation {
    
    // MARK: - Operation execution & control
    
    typealias ExecutionCallback = (Any?, LimeAuthError?)->Void
    
    /// Executes an operation
    func execute(authentication: PowerAuthAuthentication, callback: @escaping ExecutionCallback)
    
    /// Cancels an execution of the opreation.
    func cancel()
    
    /// Finish operation. You can use this for internal class cleanup (if required)
    //func finish()

    /// Returns true if operation is executing now.
    var isExecuting: Bool { get }
    
    /// Returns true if operation is cancelled.
    var isCancelled: Bool { get }
    
    /// Returns true if operation is offline (e.g. its execution uses offline signatures, or is expected
    /// that network connection is not available)
    var isOffline: Bool { get }
    
    /// Returns true if operation is already serialized in the session's queue. If operation's implementation
    /// doesn't use session's queue, then must return false.
    var isSerialized: Bool { get }
    
}


public protocol AuthenticationUIOperationExecutionLogic: class {
    
    /// The Keyboard UI can ask an operation about biometry usage after the UI presentation.
    /// Execution logic returns true if biometry signing will be used immediately after the UI presentation.
    /// The keyboard UI can use this information for UI preparation and present its internal components
    /// in way not colliding with TouchID system alert.
    ///
    /// The value returned from this method may change during the lifetime of the Keyboard UI. For example, if
    /// Touch-ID is locked down after couple of failures.
    ///
    /// If true is returned, then the Keyboard UI should execute operation with biometry when is presented
    /// for first time.
    func willUseBiometryFirst() -> Bool
    
    /// Executes operation
    func execute(for authentication: PowerAuthAuthentication, callback: @escaping (AuthenticationUIOperationResult)->Void) -> Void
    
    /// Cancels pending operation execution.
    func cancel()
    
    /// Contains true if underlying operation is cancelled.
    var isCancelled: Bool { get }
    
    /// Contains true if retry is allowed.
    var isRetryAllowed: Bool  { get }
    
    /// Contains true if biometry is allowed for underlying operation
    var isBiometryAllowed: Bool  { get }
    
    /// Contains true if operation is offline
    var isOfflineOperation: Bool  { get }
}


public struct AuthenticationUIOperationResult {
    
    public let result: Any?
    public let error: LimeAuthError?
    
    /// User did cancel TouchID dialog
    public var isTouchIdCancel: Bool = false
    
    /// TouchID is not available
    public var touchIdNotAvailable: Bool = false
    
    /// An authentication error occured (e.g. wrong PIN)
    public var isAuthenticationError: Bool = false
    
    /// PowerAuth activation is in wrong state (UI has to investigate more and react properly on that situation)
    public var activationProblem: Bool = false
    
    init(result: Any? = nil, error: LimeAuthError? = nil) {
        self.result = result
        self.error = error
    }
    
    public var isSuccess: Bool {
        return error == nil
    }
    
    public var isError: Bool {
        return error != nil
    }
}

