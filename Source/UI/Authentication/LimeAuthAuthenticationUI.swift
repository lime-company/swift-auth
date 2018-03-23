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
    public var newCredentialsRouter: (NewCredentialsRoutingLogic & AuthenticationUIProcessRouter)?
    public var enterPasswordRouter: (EnterPasswordRoutingLogic & AuthenticationUIProcessRouter)?
    

    /// Designated constructor
    public init(authenticationProcess: AuthenticationUIProcess) {
        self.authenticationProcess = authenticationProcess
    }
    
    public convenience init(session: LimeAuthSession,
                            uiProvider: AuthenticationUIProvider,
                            credentialsProvider: LimeAuthCredentialsProvider,
                            request: Authentication.UIRequest,
                            operation: AuthenticationUIOperation,
                            completion: @escaping (Authentication.Result, Authentication.UIResponse, UIViewController?)->Void) {
        let executor = AuthenticationUIOperationExecutor(session: session, operation: operation, requestOptions: request.options, credentialsProvider: credentialsProvider)
        let process = AuthenticationUIProcess(session: session, uiProvider: uiProvider, credentialsProvider: credentialsProvider, request: request, executor: executor)
        process.operationCompletion = { (result, error, object, finalController) in
            // high level completion
            completion(result, Authentication.UIResponse(result: object, error: error, cancelled: result == .cancel), finalController)
        }
        self.init(authenticationProcess: process)
    }
    
    // MARK: - UI instantiation
    
    public func instantiateEntryScene() -> UIViewController {
        var controller: UIViewController & AuthenticationUIProcessController
        switch entryScene {
        case .createPassword:
            let router = newCredentialsRouter ?? NewCredentialsRouter()
            controller = instantiateCreatePassword(router: router)
        case .enterPassword:
            let router = enterPasswordRouter ?? EnterPasswordRouter()
            controller = instantiateEnterPasswordScene(router: router)
        case .changePassword:
            let router = enterPasswordRouter ?? EnterOldPasswordRouter()
            controller = instantiateEnterPasswordScene(router: router)
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
    
    
    private func instantiateCreatePassword(router: AuthenticationUIProcessRouter & NewCredentialsRoutingLogic) -> (UIViewController & NewCredentialsRoutableController) {
        let controller = authenticationProcess.uiProvider.instantiateNewCredentialsScene()
        controller.connectCreatePasswordRouter(router: router)
        return controller
    }
    
    
    private func instantiateEnterPasswordScene(router: AuthenticationUIProcessRouter & EnterPasswordRoutingLogic) -> (UIViewController & EnterPasswordRoutableController) {
        let credentials = authenticationProcess.credentialsProvider.credentials
        let uiProvider = authenticationProcess.uiProvider
        let controller: UIViewController & EnterPasswordRoutableController
        // Choose right type of controller, based on type of password credentials
        switch credentials.password.type {
        case .fixedPin:
            controller = uiProvider.instantiateEnterFixedPasscodeScene()
        case .variablePin:
            controller = uiProvider.instantiateEnterPasscodeScene()
        case .password:
            controller = uiProvider.instantiateEnterPasswordScene()
        }
        controller.connectEnterPasswordRouter(router: router)
        return controller
    }
}

// MARK: - UI for common operations

public extension LimeAuthAuthenticationUI {
    
    /// Function returns Authentication UI preconfigured as a part of activation UI flow
    public static func uiForCreatePassword(activationProcess: ActivationUIProcess,
                                           uiProvider: AuthenticationUIProvider,
                                           completion: @escaping (Authentication.Result, LimeAuthError?, Authentication.UICredentials?, UIViewController?)->Void) -> LimeAuthAuthenticationUI {
        let authenticationProcess = AuthenticationUIProcess(activation: activationProcess, uiProvider: uiProvider)
        authenticationProcess.createCredentialsCompletion = { (result, error, credentials, finalController) in
            // Check result and if operation succeeded, then keep password in activation data & store selected complexity
            if result == .success {
                if let credentials = credentials {
                    activationProcess.activationData.password = credentials.password
                    if let passwordOptionsIndex = credentials.paswordOptionsIndex {
                        _ = activationProcess.credentialsProvider.changePasswordComplexity(passwordIndex: passwordOptionsIndex)
                    }
                } else {
                    
                }
            }
            completion(result, error, credentials, finalController)
        }
        let ui = LimeAuthAuthenticationUI(authenticationProcess: authenticationProcess)
        ui.entryScene = .createPassword
        return ui
    }
    
    
    public static func uiForChangePassword(session: LimeAuthSession,
                                           uiProvider: AuthenticationUIProvider,
                                           credentialsProvider: LimeAuthCredentialsProvider,
                                           completion: @escaping (Authentication.Result, UIViewController?)->Void) -> LimeAuthAuthenticationUI {

        let uiDataProvider = uiProvider.uiDataProvider
        let commonStrings = uiDataProvider.uiCommonStrings
        let credentials = credentialsProvider.credentials
        
        // UIRequest
        var uiRequest = Authentication.UIRequest()
        uiRequest.prompts.keyboardPrompt = credentials.password.type == .password ? commonStrings.enterOldPassword : commonStrings.enterOldPin
        uiRequest.prompts.activityMessage = ""
        uiRequest.prompts.successMessage = ""
        uiRequest.tweaks.successAnimationDelay = 450
        
        // Operation for execution
        let operation = OnlineAuthenticationUIOperation(isSerialized: true) { (session, authentication, completionCallback) -> Operation? in
            guard let password = authentication.usePassword else {
                completionCallback(nil, LimeAuthError(string: "Internal error: Password is expected."))
                return nil
            }
            return session.validatePassword(password: password) { (error) in
                if let error = error {
                    completionCallback(nil, LimeAuthError(error: error))
                } else {
                    completionCallback(nil, nil)
                }
            }
        }
        let operationExecutor = AuthenticationUIOperationExecutor(session: session, operation: operation, requestOptions: uiRequest.options, credentialsProvider: credentialsProvider)
        
        // Construct authentication process with credentials change closure
        let process = AuthenticationUIProcess(session: session, uiProvider: uiProvider, credentialsProvider: credentialsProvider, request: uiRequest, executor: operationExecutor)
        process.changeCredentialsCompletion = { (result, error, credentialsChange, finalController) in
            if let change = credentialsChange {
                _ = session.changeValidatedPassword(from: change.current.password, to: change.next.password) { (success) in
                    if success {
                        // password change did succeeded
                        if let passwordIndex = change.next.paswordOptionsIndex {
                            _ = credentialsProvider.changePasswordComplexity(passwordIndex: passwordIndex)
                        }
                        completion(.success, finalController)
                    } else {
                        // this may happen when activation is no longer valid
                        D.error("Cannot change password.")
                        completion(.failure, finalController)
                    }
                }
            } else {
                assert(result != .success)
                completion(result, finalController)
            }
        }
        let ui = LimeAuthAuthenticationUI(authenticationProcess: process)
        ui.entryScene = .changePassword
        return ui
    }
    
    
    public static func uiForRemoveActivation(session: LimeAuthSession,
                                             uiProvider: AuthenticationUIProvider,
                                             credentialsProvider: LimeAuthCredentialsProvider,
                                             completion: @escaping (Authentication.Result, UIViewController?)->Void) -> LimeAuthAuthenticationUI {
        // Build operation object
        let operation = OnlineAuthenticationUIOperation(isSerialized: true) { (session, authentication, completionCallback) -> Operation? in
            return session.removeActivation(authentication: authentication) { (error) in
                completionCallback(nil, error != nil ? LimeAuthError(error: error!) : nil)
            }
        }
        // TODO: loc
        var uiRequest = Authentication.UIRequest()
        uiRequest.prompts.activityMessage = "Removing activation from this device..."
        uiRequest.prompts.successMessage = "This device is no longer activated."
        return LimeAuthAuthenticationUI(session: session, uiProvider: uiProvider, credentialsProvider: credentialsProvider, request: uiRequest, operation: operation) { (result, uiResponse, finalController) in
            completion(result, finalController)
        }
    }
    
    
    public static func uiForEnableBiometry(session: LimeAuthSession,
                                           uiProvider: AuthenticationUIProvider,
                                           credentialsProvider: LimeAuthCredentialsProvider,
                                           completion: @escaping (Authentication.Result, UIViewController?)->Void) -> LimeAuthAuthenticationUI {
        // Build operation object
        let operation = OnlineAuthenticationUIOperation(isSerialized: true) { (session, authentication, completionCallback) -> Operation? in
            return session.addBiometryFactor(password: authentication.usePassword!) { (error) in
                completionCallback(nil, error != nil ? LimeAuthError(error: error!) : nil)
            }
        }
        // TODO: loc
        var uiRequest = Authentication.UIRequest()
        uiRequest.prompts.activityMessage = "Workinng..."
        uiRequest.prompts.successMessage = "Biometric authentication has been enabled."
        
        return LimeAuthAuthenticationUI(session: session, uiProvider: uiProvider, credentialsProvider: credentialsProvider, request: uiRequest, operation: operation) { (result, uiResponse, finalController) in
            completion(result, finalController)
        }
    }
}

