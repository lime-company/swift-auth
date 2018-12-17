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

typealias PassphraseScreenRouter = AuthenticationUIProcessRouter & EnterPasswordRoutingLogic

/// Protocol that needs to be implemented by controller that will present UI
protocol PassphraseScreenPresenter: class {
    func presentState(_ newState: PassphraseScreenModel.State, completion: (() -> Void)?)
}

// MARK: - Main class

/// ViewModel for "EnterPassphraseController" screen
class PassphraseScreenModel {
    
    /// How many attempts is remaining before activation is blocked
    var remainingAttempts: UInt32 { return router.authenticationProcess.session.lastFetchedActivationStatus?.remainingAttempts ?? 0 }
    /// How many failed attempts user already did
    var failAttempts: UInt32 { return router.authenticationProcess.session.lastFetchedActivationStatus?.failCount ?? 0 }
    /// Biometry is ready from both perspectives (system & powerauth)
    var isBiometryAllowed: Bool { return router.authenticationProcess.operationExecution?.isBiometryAllowed ?? false }
    let credentialsType: LimeAuthCredentials.Password
    let credentialsIndex: Int // index of the password type as saved in the preferences
    let operationType: OperationType
    
    private var uiRequest: Authentication.UIRequest { return router.authenticationProcess.uiRequest }
    
    private let router: PassphraseScreenRouter
    private(set) var state = State.initial
    private var stateLock = false
    private unowned var presenter: PassphraseScreenPresenter // controller
    private var operation: PassPhraseOperation! // operation that will be executed when user entered and confirmed password/PIN
    
    init(router: PassphraseScreenRouter, operation: OperationType, credentialsType: LimeAuthCredentials.Password, credentialsIndex: Int, parent: PassphraseScreenPresenter) {
        
        self.router = router
        self.presenter = parent
        self.credentialsType = credentialsType
        self.credentialsIndex = credentialsIndex
        self.operationType = operation
        
        switch operation {
        case .authorize:
            self.operation = PassPhraseAuhorize(model: self)
        case .createPassword: // or change
            self.operation = PassPhraseCreate(model: self)
        }
    }
    
    /// When controller is ready, call this method to inform model
    func startModel() {
        
        changeState(.enterPassword(false))
        
        if router.authenticationProcess.operationExecution?.willUseBiometryFirst() == true {
            confirmWithBiometry()
        }
    }
    
    func confirm(withPassword password: String) {
        operation.execute(.password(password))
    }
    
    func confirmWithBiometry() {
        guard isBiometryAllowed else {
            return
        }
        operation.execute(.biometry)
    }
    
    func navigateToCancel() {
        router.routeToCancel()
    }
    
    private func navigateToSuccess() {
        router.routeToSuccess()
    }
    
    private func navigateToError(error: LimeAuthError?) {
        router.routeToError(error: error)
    }
    
    private func changeState(_ state: State, completion: (() -> Void)? = nil) {
        
        guard stateLock == false else {
            D.warning("Cannot change state during state lock")
            return
        }
        
        stateLock = true
        
        let compl = {
            self.stateLock = false
            self.state = state
            completion?()
        }
        
        presenter.presentState(state, completion: compl)
    }
    
    // MARK: - Helper enum/classes
    
    /// State that is currelntly displayed by the model
    enum State {
        case initial
        case enterPassword(_ animate: Bool)
        case activity(_ animate: Bool)
        case success(_ animate: Bool)
        case error(_ result: AuthenticationUIOperationResult)
    }
    
    /// Type of operation that is model presenting
    enum OperationType {
        case authorize
        case createPassword
    }
    
    /// How operation should be confirmed
    private enum OperationCredentials {
        case biometry
        case password(String)
    }
    
    /// "Abstract" class for model operation
    private class PassPhraseOperation {
        fileprivate unowned var model: PassphraseScreenModel
        init(model: PassphraseScreenModel) {
            self.model = model
        }
        func execute(_ credentials: PassphraseScreenModel.OperationCredentials) {
            D.fatalError("To override")
        }
    }
    
    /// Concrete implementation of "Auhtorization/Verification" operation
    private class PassPhraseAuhorize: PassPhraseOperation {
        override func execute(_ credentials: PassphraseScreenModel.OperationCredentials) {
            
            let authentication = PowerAuthAuthentication()
            
            switch credentials {
            case .biometry:
                authentication.useBiometry = true
                authentication.biometryPrompt = model.uiRequest.prompts.biometricPrompt
            case .password(let password):
                authentication.usePassword = password
            }
            
            model.changeState(.activity(true)) {
                self.model.router.authenticationProcess.operationExecution.execute(for: authentication) { result in
                    if result.isError, let error = result.error {
                        self.model.router.authenticationProcess.storeFailureReason(error: error)
                        if result.isTouchIdCancel {
                            self.model.changeState(.enterPassword(true))
                        } else if result.isAuthenticationError {
                            if result.isActivationProblem {
                                self.model.changeState(.error(result))
                            } else {
                                self.model.changeState(.error(result)) {
                                    self.model.changeState(.enterPassword(true))
                                }
                            }
                        }
                    } else {
                        self.model.changeState(.success(true)) {
                            self.model.router.authenticationProcess.storeCurrentCredentials(credentials: Authentication.UICredentials(password: authentication.usePassword ?? ""))
                            self.model.navigateToSuccess()
                        }
                    }
                }
            }
        }
    }
    
    /// Concrete implementation of "Password changing/creating" operation
    private class PassPhraseCreate: PassPhraseOperation {
        override func execute(_ credentials: PassphraseScreenModel.OperationCredentials) {
            switch credentials {
            case .biometry:
                assertionFailure("Biometry is not allowed in this case")
            case .password(let password):
                self.model.router.authenticationProcess.storeNextCredentials(credentials: Authentication.UICredentials(password: password, optionsIndex: self.model.credentialsIndex))
                self.model.presenter.presentState(.success(true)) {
                    self.model.navigateToSuccess()
                }
            }
        }
    }
}
