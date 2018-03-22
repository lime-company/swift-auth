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

public protocol AuthenticationUIProvider: class {

    func instantiateNewCredentialsScene() -> (UIViewController & NewCredentialsRoutableController)
    
    func instantiateEnterPasswordScene() -> (UIViewController & EnterPasswordRoutableController)
    func instantiateEnterPasscodeScene() -> (UIViewController & EnterPasswordRoutableController)
    func instantiateEnterFixedPasscodeScene() -> (UIViewController & EnterPasswordRoutableController)
    
    func instantiateNavigationController(with rootController: UIViewController) -> UINavigationController?
    
    var uiDataProvider: AuthenticationUIDataProvider { get }
}

public protocol AuthenticationUIDataProvider: class {
    
    var uiCommonStrings: Authentication.UIData.CommonStrings { get }
    var uiCommonImages: Authentication.UIData.CommonImages { get }
    var uiCommonStyle: Authentication.UIData.CommonStyle { get }
    var uiCommonErrors: Authentication.UIData.CommonErrors { get }
    
    // Per scene getters
    
    var uiForCreateNewPassword: NewCredentials.UIData { get }
    
    // Localization function
    
    func localizePasswordComplexity(option: LimeAuthCredentials.Password) -> String
    func localizeRemainingAttempts(attempts: UInt32) -> String
}

public protocol AuthenticationUIProcessRouter: class {
    var authenticationProcess: AuthenticationUIProcess! { get set }
    func connect(controller: AuthenticationUIProcessController)
}

public protocol AuthenticationUIProcessController: class {
    func connect(authenticationProcess process: AuthenticationUIProcess)
}



public class AuthenticationUIProcess {
    
    public let session: LimeAuthSession
    public let uiProvider: AuthenticationUIProvider
    public var uiDataProvider: AuthenticationUIDataProvider {
        return uiProvider.uiDataProvider
    }
    public let credentialsProvider: LimeAuthCredentialsProvider
    
    /// Request data. Valid only if process is not part of activation
    public let uiRequest: Authentication.UIRequest!
    
    /// Operation executer, valid only if process is not part of activation
    public let operationExecution: AuthenticationUIOperationExecutionLogic!
    
    /// Contains parent ActivationUIProcess. Property contains valid object only when this process
    /// is part of activation UI flow.
    public let activationProcess: ActivationUIProcess!
    
    public var isPartOfActivation: Bool {
        return activationProcess != nil
    }
    
    public internal(set) weak var initialController: UIViewController?
    public internal(set) weak var finalController: UIViewController?
    
    public private(set) var processResult: Authentication.Result = .cancel
    public private(set) var processError: LimeAuthError?
    public private(set) var operationResponse: Any?
    
    public private(set) var currentCredentials: Authentication.UICredentials?
    public private(set) var nextCredentials: Authentication.UICredentials?
    
    // Completion closures
    public var operationCompletion: ((Authentication.Result, LimeAuthError?, Any?, UIViewController?)->Void)?
    public var createCredentialsCompletion: ((Authentication.Result, LimeAuthError?, Authentication.UICredentials?, UIViewController?)->Void)?
    public var changeCredentialsCompletion: ((Authentication.Result, LimeAuthError?, Authentication.UICredentialsChange?, UIViewController?)->Void)?
    
    // Constructor for authentication operations
    public init(session: LimeAuthSession, uiProvider: AuthenticationUIProvider, credentialsProvider: LimeAuthCredentialsProvider, request: Authentication.UIRequest, executor: AuthenticationUIOperationExecutionLogic) {
        self.session = session
        self.uiProvider = uiProvider
        self.credentialsProvider = credentialsProvider
        self.uiRequest = request
        self.operationExecution = executor
        self.activationProcess = nil
    }
    
    // Special constructor for activation purposes.
    public init(activation: ActivationUIProcess, uiProvider: AuthenticationUIProvider) {
        self.session = activation.session
        self.uiProvider = uiProvider
        self.credentialsProvider = activation.credentialsProvider
        self.uiRequest = nil
        self.operationExecution = nil
        self.activationProcess = activation
    }
    
    
    // Completes process
    
    public func completeAuthentication(controller: UIViewController?, response: Any? = nil) {
        finalController = controller
        if !isPartOfActivation {
            // not a part of activation
            if response != nil {
                operationResponse = response
            }
        } else {
            // part of activation, check whether password has been set
            assert(nextCredentials != nil, "Password is missing")
        }
        presentResult(result: .success)
    }
    
    public func cancelAuthentication(controller: UIViewController?) {
        finalController = controller
        presentResult(result: .cancel)
    }
    
    public func failAuthentication(controller: UIViewController?, with error: LimeAuthError? = nil) {
        finalController = controller
        if error != nil {
            processError = error
        }
        presentResult(result: .failure)
    }
    
    public func storeSuccessObject(response: Any) {
        operationResponse = response
    }
    
    public func storeFailureReason(error: LimeAuthError) {
        processError = error
    }
    
    public func storeCurrentCredentials(credentials: Authentication.UICredentials) {
        currentCredentials = credentials
    }
    
    public func storeNextCredentials(credentials: Authentication.UICredentials) {
        nextCredentials = credentials
    }
    
    private func presentResult(result: Authentication.Result) {
        processResult = result
        if let completion = operationCompletion {
            completion(processResult, processError, operationResponse, finalController)
        } else if let completion = createCredentialsCompletion {
            completion(processResult, processError, nextCredentials, finalController)
        } else if let completion = changeCredentialsCompletion {
            let change: Authentication.UICredentialsChange?
            if let curr = currentCredentials, let next = nextCredentials {
                change = Authentication.UICredentialsChange(current: curr, next: next)
            } else {
                change = nil
            }
            completion(processResult, processError, change, finalController)
        }
    }
}
