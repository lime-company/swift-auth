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

public protocol AuthenticationUIProvider {

    func instantiateCreateCredentialsScene() -> (UIViewController & CreatePasswordRoutableController)
    
    func instantiateEnterPasswordScene() -> (UIViewController & EnterPasswordRoutableController)
    func instantiateExterPasscodeScene() -> (UIViewController & EnterPasswordRoutableController)
    func instantiateEnterFixedPasscodeScene() -> (UIViewController & EnterPasswordRoutableController)
    
    func instantiateNavigationController(with rootController: UIViewController) -> UINavigationController?
    
    var uiDataProvider: AuthenticationUIDataProvider { get }
}


public protocol AuthenticationUIDataProvider {
    
    var uiCommonStrings: Authentication.UIData.CommonStrings { get }
    var uiCommonImages: Authentication.UIData.CommonImages { get }
    var uiCommonStyle: Authentication.UIData.CommonStyle { get }
    
    func localizePasswordComplexity(option: LimeAuthCredentials.Password) -> String
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
    
    public internal(set) var uiResponse: Authentication.UIResponse?
    
    public internal(set) weak var initialController: UIViewController?
    public internal(set) weak var finalController: UIViewController?
    
    public internal(set) var validCredentials: PowerAuthAuthentication?
    public internal(set) var nextCredentials: PowerAuthAuthentication?
    
    public var completion: ((Authentication.UIResponse)->Void)?
    
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
        if response != nil {
            uiResponse = Authentication.UIResponse(result: response, error: nil, cancelled: false)
        }
        presentResult()
    }
    
    public func cancelAuthentication(controller: UIViewController?) {
        finalController = controller
        uiResponse = Authentication.UIResponse(result: nil, error: nil, cancelled: true)
        presentResult()
    }
    
    public func failAuthentication(controller: UIViewController?, with error: LimeAuthError? = nil) {
        finalController = controller
        if error != nil {
            uiResponse = Authentication.UIResponse(result: nil, error: error, cancelled: false)
        }
        presentResult()
    }
    
    public func storeSuccessObject(response: Any) {
        uiResponse = Authentication.UIResponse(result: response, error: nil, cancelled: false)
    }
    
    public func storeFailureReason(error: LimeAuthError) {
        uiResponse = Authentication.UIResponse(result: nil, error: error, cancelled: false)
    }
    
    public func storeValidCredentials(authentication: PowerAuthAuthentication) {
        validCredentials = authentication
    }
    
    public func storeNextCredentials(authentication: PowerAuthAuthentication) {
        nextCredentials = authentication
    }
    
    private func presentResult() {
        if let completion = completion {
            let response = uiResponse ?? Authentication.UIResponse(result: nil, error: nil, cancelled: true)
            completion(response)
        } else {
            D.print("AuthenticationUIProcess: There's no completion block assigned.")
        }
    }
}


public protocol AuthenticationUIProcessRouter: class {
    var authenticationProcess: AuthenticationUIProcess! { get set }
}

public protocol AuthenticationUIProcessController: class {
    func connect(authenticationProcess process: AuthenticationUIProcess)
}
