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

public class AuthenticationUIOperationExecutor: AuthenticationUIOperationExecutionLogic {

    private enum State {
        case initialized
        case executing
        case failed
        case succeeded
        case completed
        case cancelled
    }
    
    let session: LimeAuthSession
    let operation: AuthenticationUIOperation
    let credentialsProvider: LimeAuthCredentialsProvider
    var requestOptions: Authentication.UIRequest.Options

    private var state: State = .initialized
    private var canRetryAfterFailedBiometry: Bool = true
    private weak var updateStatusOperation: Operation? = nil
    private weak var synchronizedOperation: Operation? = nil
    
    init(session: LimeAuthSession, operation: AuthenticationUIOperation, requestOptions: Authentication.UIRequest.Options, credentialsProvider: LimeAuthCredentialsProvider) {
        self.session = session
        self.operation = operation
        self.requestOptions = requestOptions
        self.credentialsProvider = credentialsProvider
        sanitizeRequestOptions()
    }

    // MARK: - AuthenticationUIOperationExecutionLogic protocol
    
    public func willUseBiometryFirst() -> Bool {
        return requestOptions.contains(.askFirstForBiometryFactor)
    }
    
    public func execute(for authentication: PowerAuthAuthentication, callback: @escaping (AuthenticationUIOperationResult) -> Void) {
        if let failure = validateExecution(authentication) {
            callback(failure)
            return
        }
        doExecute(authentication, callback)
    }
    
    public func cancel() {
        if state != .completed && state != .cancelled {
            // allow cancel in any state, except cancelled & completed
            state = .cancelled
            operation.cancel()
            updateStatusOperation?.cancel()
            updateStatusOperation = nil
            synchronizedOperation?.cancel()
            synchronizedOperation = nil
        } else {
            D.warning("cancel() called when already cancelled or finished")
        }
    }
    
    public var isCancelled: Bool {
        return state == .cancelled
    }
    
    public var isBiometryAllowed: Bool {
        return requestOptions.contains(.allowBiometryFactor)
    }
    
    public var isOfflineOperation: Bool {
        return operation.isOffline
    }
    
    // MARK: - Private methods
    
    private func sanitizeRequestOptions() {
        let credentials = credentialsProvider.credentials
        let biometryOption: LimeAuthCredentials.Biometry.Option
        
        // First chech if biometry is setup and is system-available
        if session.hasBiometryFactor && PowerAuthKeychain.canUseBiometricAuthentication {
            // Translate supported biometric authentication to biometry option enum.
            switch LimeAuthSession.supportedBiometricAuthentication {
            case .touchID: biometryOption = credentials.biometry.touchId
            case .faceID: biometryOption = credentials.biometry.faceId
            case .none: biometryOption = .disabled
            @unknown default: D.fatalError("unknown factor")
            }
        } else {
            biometryOption = .disabled
        }
        // Now apply that option and remove incompatible flags requested by the application
        switch biometryOption {
        case .enabledAndAutomatic:
            // Do nothing, we don't need to sanitize filter.
            break
        case .enabledOnDemand:
            // Remove only "ask first" flag, but biometry may be used
            self.requestOptions.remove(.askFirstForBiometryFactor)
        case .disabled:
            // Remove all biomety related flags.
            self.requestOptions.remove([.allowBiometryFactor, .askFirstForBiometryFactor])
        }
    }
    
    private func validateExecution(_ authentication: PowerAuthAuthentication) -> AuthenticationUIOperationResult? {
        var errorReason: String?
        // validate state
        if state != .initialized {
            // Following errors are mostly internal errors. You have error in keyboard logic if this occurs.
            if state == .executing {
                errorReason = "Operation is already in progress."
            } else if state == .succeeded {
                errorReason = "Operation already succeeded."
            } else if state == .cancelled {
                errorReason = "Operation already cancelled."
            } else if state == .completed {
                errorReason = "Operation is already completed."
            }
        }
        // validate execution conditions
        if authentication.useBiometry && !isBiometryAllowed {
            // Also internal error in Keyboard logic
            errorReason = "Biometry factor is not allowed for this operation."
        }
        if let errorReason = errorReason {
            return AuthenticationUIOperationResult(error: LimeAuthError(string: errorReason))
        }
        // Update possession flag
        authentication.usePossession = requestOptions.contains(.usePossession)
        return nil
    }

    private func doExecute(_ auth: PowerAuthAuthentication, _ callback: @escaping (AuthenticationUIOperationResult) -> Void) {
        
        // change state
        canRetryAfterFailedBiometry = false
        state = .executing
        
        // ...aand execute the operation
        if operation.isSerialized {
            // Already serialized operations can be executed directly. We're expecting that callback is called to main thread.
            operation.execute(session: session, authentication: auth) { (result, error) in
                self.processExecutionResult(auth: auth, result: result, error: error, callback: callback)
            }
            //
        } else {
            // Wrap execution to operation serialized in session's serialization queue
            let op = AsyncBlockOperation { _, markFinished in
                
                self.operation.execute(session: self.session, authentication: auth) { result, error in
                    self.processExecutionResult(auth: auth, result: result, error: error, callback: callback)
                    markFinished(nil)
                }
            }
            synchronizedOperation = session.addOperationToQueue(op, serialized: true)
        }
    }
    
    private func processExecutionResult(auth: PowerAuthAuthentication, result: Any?, error: LimeAuthError?, callback: @escaping (AuthenticationUIOperationResult) -> Void) {
        if let err = error {
            var response = AuthenticationUIOperationResult(error: error)
            // At first, check if it's Touch-ID cancel or error, we can report this immediately to the completion
            if self.checkTouchIdError(&response) {
                self.state = .failed
                callback(response)
                return
            }
            // Check if operation ended on auth error
            if err.httpStatusCode == 401 {
                response.isAuthenticationError = true
                response.isBiometryError = auth.useBiometry
            }
            // If not offline, then check whether is network available.
            if !self.operation.isOffline {
                if self.checkOnlineConnection(&response) {
                    // Looks like we're still connected to the internet, so update PA status now
                    self.updateActivationStatus(response, .failed, callback)
                    return
                }
            }
            // Operation is "offline" or network is not available
            self.state = .failed
            callback(response)
        } else {
            self.state = .succeeded
            let response = AuthenticationUIOperationResult(result: result)
            callback(response)
            // Check silently for status update. If status is not available, then defaulting to 1, to force update
            if (self.session.lastFetchedActivationStatus?.failCount ?? 1) != 0 {
                self.session.setNeedUpdateActivationStatus()
            }
        }
    }
    
    private func checkTouchIdError(_ response: inout AuthenticationUIOperationResult) -> Bool {
        // At first, validate whether touchid is still available
        if requestOptions.contains([.allowBiometryFactor]) {
            let credentials = credentialsProvider.credentials
            if !credentials.biometry.isSupportedOnDevice {
                // Looks like touch id / face id, is not available after this attempt
                requestOptions.remove([.allowBiometryFactor, .askFirstForBiometryFactor])
                response.touchIdNotAvailable = true
            }
        }
        // Now validate the error
        if let error = response.error, let code = error.powerAuthErrorCode {
            if code == .biometryCancel {
                // User did cancel the operation
                response.isTouchIdCancel = true
                canRetryAfterFailedBiometry = true
                return true
                //
            } else if code == .biometryNotAvailable {
                // Touch-ID is not supported.
                // This usually means a broken keyboard logic, but we still can report the error
                response.touchIdNotAvailable = true
                return true
            }
        }
        return false
    }
    
    private func checkOnlineConnection(_ response: inout AuthenticationUIOperationResult) -> Bool {
        if let error = response.error {
            if error.domain == kCFErrorDomainCFNetwork as String {
                if Int32(error.code) == CFNetworkErrors.cfurlErrorNotConnectedToInternet.rawValue {
                    return false
                }
            }
            // TODO: check for reachability?
            // Looks like we're online
        }
        return true
    }
    
    private func updateActivationStatus(_ response: AuthenticationUIOperationResult, _ nextState: State, _ callback: @escaping (AuthenticationUIOperationResult) -> Void) {
        updateStatusOperation = session.fetchActivationStatus { (status, _, error) in
            self.updateStatusOperation = nil
            self.state = nextState
            if let st = status {
                var responseCopy = response
                responseCopy.isActivationProblem = st.state != .active
                responseCopy.activationState = st.state
                callback(responseCopy)
            } else {
                callback(response)
            }
        }
    }
}
