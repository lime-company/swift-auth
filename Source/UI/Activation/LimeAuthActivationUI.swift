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

public class LimeAuthActivationUI {
    
    public enum EntryScene {
        /// Start of activation UI flow is determined by state of the session. If session has activation
        /// and it's state is `otp_Used`, then the `confirmation` scene is used, otherwise `initial`
        case `default`
        /// Activation UI flow will begin in initial scene. The provided session must be empty.
        case initial
        /// Activation UI flow will begin in QR code scanner. The provided session must be empty.
        case scanCode
        /// Activation UI flow will begin in entering activation scene. The provided session must be empty.
        case enterCode
        /// Activation UI flow will begin in confirmation cene. The provided session contain valid activation in `otp_Used` state.
        case confirmation
    }
    
    /// Entry scene. You can adjust this variable before you invoke UI construction.
    public var entryScene: EntryScene
    
    /// UI provider
    private var uiProvider: ActivationUIProvider
    
    /// Internal activation process
    private var activationProcess: ActivationProcess
    
    /// Completion closure
    private var completion: ((Activation.Result, UIViewController?)->Void)?
    
    
    public init(session: LimeAuthSession, uiProvider: ActivationUIProvider, completion: @escaping (Activation.Result, UIViewController?)->Void ) {
        self.activationProcess = ActivationProcess(session: session, uiDataProvider: uiProvider.uiDataProvider)
        self.uiProvider = uiProvider
        self.completion = completion
        self.entryScene = .default
    }
    
    
    /// Function invokes initial scene
    public func invokeEntryScene() -> UIViewController {
        // Validate whether this invoke can be processed
        validateEntryScene()
        // Construct appropriate controller
        var controller: UIViewController & ActivationProcessController
        switch entryScene {
        case .initial:
            controller = uiProvider.instantiateInitialScene()
        case .enterCode:
            controller = uiProvider.instantiateEnterCodeScene()
        case .scanCode:
            controller = uiProvider.instantiateScanCodeScene()
        case .confirmation:
            // In this case, there's no activation result.
            activationProcess.activationData.noActivationResult = true
            controller = uiProvider.instantiateConfirmScene()
        default:
            fatalError()    // shold never happen
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
        let entryScene = invokeEntryScene()
        navigationController.pushViewController(entryScene, animated: animated)
    }
    
    
    /// Function invokes entry scene and presents it modally into provided controller. The appropriate navigation controller is
    /// constructed automatically, when `AuthenticationUIProvider` uses navigation stack.
    public func present(to controller: UIViewController, animated: Bool = true, completion: (()->Void)? = nil) {
        let entryScene = invokeEntryScene()
        var controllerToPresent = entryScene
        if let navigationController = uiProvider.instantiateNavigationController(with: entryScene) {
            controllerToPresent = navigationController
        }
        controller.present(controllerToPresent, animated: animated, completion: completion)
    }
    
    

    // MARK: - Private methods
    
    /// Internally validates entry scene configuration against current session's state.
    private func validateEntryScene() {
        
        let hasActivation = activationProcess.session.hasValidActivation
        let canStartActivation = activationProcess.session.canStartActivation
        let hasOtpUsed = hasActivation && (activationProcess.session.lastFetchedActivationStatus?.state ?? .created)  == .otp_Used
        
        var wrongState = false
        
        switch entryScene {
        case .default:
            if hasActivation && hasOtpUsed {
                entryScene = .confirmation
            } else if canStartActivation {
                entryScene = .initial
            } else {
                wrongState = true
            }
        case .initial:
            wrongState = !canStartActivation
        case .scanCode:
            wrongState = !canStartActivation
        case .enterCode:
            wrongState = !canStartActivation
        case .confirmation:
            wrongState = !hasOtpUsed
        }
        // Throw error if we cannot process scene for current session's state
        if wrongState {
            fatalError("LimeAuthActivationUI: Invoking activation UI when session's state is wrong or is not determined yet.")
        }
    }
    
    ///
    private func complete(with activationData: Activation.Data) {
        completion?(activationData.result ?? .cancel, activationProcess.finalController)
        completion = nil
    }

}
