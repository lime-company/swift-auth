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

public class LimeAuthAuthenticationUI {
    
    public enum EntryScene {
        /// Authentication UI will begin with scene for creating a new password
        case createPassword
        /// Authentication UI will begin with scene for entering password.
        /// This is the default value.
        case enterPassword
        /// Authentication UI will begin with scene for change password
        case changePassword
    }
    
    public let authenticationProcess: AuthenticationUIProcess
    public var entryScene: EntryScene = .enterPassword
    
    /// Optional, you can adjust router which will be used
    public var createPasswordRouter: CreatePasswordRoutingLogic?
    public var enterPasswordRouter: EnterPasswordRoutingLogic?
    
    public init(authenticationProcess: AuthenticationUIProcess) {
        self.authenticationProcess = authenticationProcess
    }
    
    
    
    public func instantiateEntryScene() -> UIViewController {
        var controller: UIViewController & AuthenticationUIProcessController
        switch entryScene {
        case .createPassword:
            controller = instantiateCreatePassword(router: CreatePasswordRouter())
        case .enterPassword:
            controller = instantiateEnterPasswordScene(router: EnterPasswordRouter())
        case .changePassword:
            controller = instantiateEnterPasswordScene(router: EnterOldPasswordRouter())
        }
        controller.connect(authenticationProcess: authenticationProcess)
        authenticationProcess.initialController = controller
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
        if let navigationController = authenticationProcess.uiProvider.instantiateNavigationController(with: entryScene) {
            controllerToPresent = navigationController
        }
        controller.present(controllerToPresent, animated: animated, completion: completion)
    }
    
    
    
    // MARK: - Private methods
    
    
    private func instantiateCreatePassword(router: CreatePasswordRoutingLogic) -> (UIViewController & CreatePasswordRoutableController) {
        let controller = authenticationProcess.uiProvider.instantiateCreateCredentialsScene()
        controller.connectCreatePasswordRouter(router: router)
        return controller
    }
    
    
    private func instantiateEnterPasswordScene(router: EnterPasswordRoutingLogic) -> (UIViewController & EnterPasswordRoutableController) {
        let credentials = authenticationProcess.credentialsProvider.credentials
        let uiProvider = authenticationProcess.uiProvider
        let controller: UIViewController & EnterPasswordRoutableController
        // Choose right type of controller, based on type of password credentials
        switch credentials.password.type {
        case .fixedPin:
            controller = uiProvider.instantiateEnterFixedPasscodeScene()
        case .variablePin:
            controller = uiProvider.instantiateEnterPasswordScene()
        case .password:
            controller = uiProvider.instantiateEnterPasswordScene()
        }
        controller.connectEnterPasswordRouter(router: router)
        return controller
    }
}


public extension LimeAuthAuthenticationUI {
    
    /// Function returns Authentication UI
    public static func uiForCreatePassword(activationProcess: ActivationUIProcess, uiProvider: AuthenticationUIProvider) -> LimeAuthAuthenticationUI {
        let authenticationProcess = AuthenticationUIProcess(activation: activationProcess, uiProvider: uiProvider)
        let ui = LimeAuthAuthenticationUI(authenticationProcess: authenticationProcess)
        ui.entryScene = .createPassword
        return ui
    }
    
}

