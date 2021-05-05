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

import UIKit
import PowerAuth2

public class LimeAuthActivationUI {
    
    public typealias CompletionClosure = (_ result: Activation.Result, _ finalController: UIViewController?)->Void
    
    /// Entry scene. You can adjust this variable before you invoke UI construction.
    public var entryScene: EntryScene
    
    /// Internal activation process
    private let activationProcess: ActivationUIProcess
    
    /// Completion closure
    private var completion: CompletionClosure?
    
    
    /// Creates instance of Activation UI
    /// - Parameters:
    ///   - session: started limeauth session
    ///   - uiProvider: ui configuration
    ///   - uiRecoveryProvider: recovery ui configuration
    ///   - credentialsProvider: credentials configuration
    ///   - additionalOTP: otp configuration. Note that this configuration does not have any effect during recovery activation
    ///   - completion: completion closure
    public init(session: LimeAuthSession,
                uiProvider: ActivationUIProvider,
                uiRecoveryProvider: RecoveryUIProvider,
                credentialsProvider: LimeAuthCredentialsProvider,
                additionalOTP: AdditionalOTP,
                completion: @escaping CompletionClosure) {
        self.activationProcess = ActivationUIProcess(
            session: session,
            uiProvider: uiProvider,
            uiRecoveryProvider: uiRecoveryProvider,
            credentialsProvider: credentialsProvider,
            additionalOTP: additionalOTP
        )
        self.completion = completion
        self.entryScene = .default
    }
    
    // MARK: - Public API
    
    /// Function invokes initial scene
    public func instantiateEntryScene() -> UIViewController {
        // Validate whether this invoke can be processed
        validateEntryScene()
        // Construct appropriate controller
        let uiProvider = activationProcess.uiProvider
        var controller: UIViewController & ActivationUIProcessController
        switch entryScene {
        case .selfActivationInitial:
            controller = uiProvider.instantiateInitialScene()
        case .selfActivationEnterCode:
            controller = uiProvider.instantiateEnterCodeScene()
        case .selfActivationScanCode:
            controller = uiProvider.instantiateScanCodeScene()
        case .selfActivationWithCode(let code):
            activationProcess.activationData.activationCode = code
            controller = uiProvider.instantiateOTPAuthenticationScene()
        case .confirmation:
            controller = controllerForRecoveryFromBrokenActivation()
        case .recoveryInitial:
            controller = uiProvider.instantiateRecoveryInitialScene()
        case .recoveryEnterCode:
            controller = uiProvider.instantiateRecoveryEnterCodeScene()
        case .default:
            D.fatalError("Flow error") // this should never happened
        }
        
        // Connect objects...
        self.activationProcess.completion = { [weak self] (data) in
            self?.complete(with: data)
        }
        activationProcess.initialController = controller
        controller.connect(activationProcess: activationProcess)
        return controller
    }
    
    /// Function invokes entry scene and pushes it into the provided navigation controller.
    public func pushEntryScene(to navigationController: UINavigationController, animated: Bool = true) {
        let entryScene = instantiateEntryScene()
        navigationController.pushViewController(entryScene, animated: animated)
    }
    
    
    /// Function invokes entry scene and presents it modally into provided controller. The appropriate navigation controller is
    /// constructed automatically, when `AuthenticationUIProvider` uses navigation stack.
    public func present(to controller: UIViewController, animated: Bool = true, completion: (()->Void)? = nil) {
        let entryScene = instantiateEntryScene()
        var controllerToPresent = entryScene
        if let navigationController = activationProcess.uiProvider.instantiateNavigationController(with: entryScene) {
            controllerToPresent = navigationController
        }
        controller.present(controllerToPresent, animated: animated, completion: completion)
    }
    
    // MARK: - Private helpers
    
    /// Function returns confirmation or error scene controller depending on whether it's possible to recovery from
    /// a broken activation.
    private func controllerForRecoveryFromBrokenActivation() -> UIViewController & ActivationUIProcessController {
        let uiProvider = activationProcess.uiProvider
        if let activationFingerprint = activationProcess.session.activationFingerprint {
            // In this case, there's no full activation result available, but we can restore at least activation fingerprint.
            let activationResult = PowerAuthActivationResult()
            activationResult.activationFingerprint = activationFingerprint
            activationProcess.activationData.recoveryFromFailedActivation = true
            activationProcess.activationData.createActivationResult = activationResult
            return uiProvider.instantiateConfirmScene()
        }
        D.error("Cannot recovery from previously broken activation.")
		activationProcess.activationData.failureReason = LimeAuthError(string: uiProvider.uiDataProvider.uiDataForConfirmActivation.errors.recoveryFailure)
        return uiProvider.instantiateErrorScene()
    }

    // MARK: - Private methods
    
    /// Internally validates entry scene configuration against current session's state.
    private func validateEntryScene() {
        
        let hasActivation = activationProcess.session.hasValidActivation
        let canStartActivation = activationProcess.session.canStartActivation
        let isPending = hasActivation && (activationProcess.session.lastFetchedActivationStatus?.state ?? .created) == .pendingCommit
        
        var wrongState = false
        
        switch entryScene {
        case .default:
            if hasActivation && isPending {
                entryScene = .confirmation
            } else if canStartActivation {
                entryScene = .selfActivationInitial
            } else {
                wrongState = true
            }
        case .selfActivationInitial, .selfActivationScanCode, .selfActivationEnterCode, .selfActivationWithCode:
            wrongState = !canStartActivation
        case .confirmation:
            wrongState = !isPending
        case .recoveryInitial:
            wrongState = !canStartActivation
        case .recoveryEnterCode:
            wrongState = !canStartActivation
        }
        // Throw error if we cannot process scene for current session's state
        if wrongState {
            D.fatalError("LimeAuthActivationUI: Invoking activation UI when session's state is wrong or is not determined yet.")
        }
    }
    
    /// Mark process as finished
    private func complete(with activationData: Activation.Data) {
        completion?(activationData.result ?? .cancel, activationProcess.finalController)
        completion = nil
    }
    
    // MARK: - Nested classes
    
    /// Configuration for additional OTP confirmation.
    /// For example when user has to authenticate via additional SMS or other channel.
    public enum AdditionalOTP {
        case none
        case authentication
        // NOT AVAILABLE YET
        //case confirmation
    }

    /// Entry scene for the activation UI
    public enum EntryScene {
        /// Start of activation UI flow is determined by state of the session. If session has activation
        /// and it's state is `otp_Used`, then the `confirmation` scene is used, otherwise `selfActivationInitial`
        case `default`
        
        // SELF ACTIVATION
        
        /// Activation UI flow will begin in initial scene. The provided session must be empty.
        case selfActivationInitial
        /// Activation UI flow will begin in QR code scanner. The provided session must be empty.
        case selfActivationScanCode
        /// Activation UI flow will begin in entering activation scene. The provided session must be empty.
        case selfActivationEnterCode
        /// Activation code was already obtained and passed to LimeAuthActivationUI. The provided session must be empty.
        case selfActivationWithCode(_ code: String)
        
        // RECOVERY ACTIVATION
        
        /// Activation UI flow will begin in initial recovery scene. The provided session must be empty.
        case recoveryInitial
        /// Activation UI flow will begin in entering recovery code scene. The provided session must be empty.
        case recoveryEnterCode
        
        // OTHER
        
        /// Activation UI flow will begin in confirmation scene. The provided session contains valid activation in `otp_Used` state.
        case confirmation
    }
}
