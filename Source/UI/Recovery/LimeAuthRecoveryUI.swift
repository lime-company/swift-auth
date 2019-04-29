//
// Copyright 2019 Wultra s.r.o.
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

public class LimeAuthRecoveryUI {
    
    private let uiProvider: RecoveryUIProvider
    
    public init(uiProvider: RecoveryUIProvider) {
        self.uiProvider = uiProvider
    }
}

public extension LimeAuthRecoveryUI {
    
    /// Creates a `LimeAuthAuthenticationUI` object that will authenticate the user and then displays his recovery code.
    /// Before using this, you should make sure that the recovery codes are supported via `LimeAuthSession.hasRecoveryActivation` property.
    static func uiForShowRecovery(session: LimeAuthSession,
                                  uiAuthProvider: AuthenticationUIProvider,
                                  uiRecoveryProvider: RecoveryUIProvider,
                                  credentialsProvider: LimeAuthCredentialsProvider,
                                  completion: @escaping (Authentication.Result, UIViewController?)->Void) -> LimeAuthAuthenticationUI {
        
        let opStrings = uiAuthProvider.uiDataProvider.uiOperationStrings
        let credentials = credentialsProvider.credentials
        
        // UIRequest
        var uiRequest = Authentication.UIRequest()
        uiRequest.options = [ .usePossession ]
        let prompt = credentials.password.type == .password ? opStrings.changePassword_PromptPassword : opStrings.changePassword_PromptPin
        uiRequest.prompts.keyboardPrompt = prompt
        uiRequest.prompts.activityMessage = opStrings.recovery_Activity
        uiRequest.prompts.successMessage = ""
        uiRequest.tweaks.successAnimationDelay = 850
        
        var resultData: LimeAuthRecoveryData?
        
        let operation = OnlineAuthenticationUIOperation(isSerialized: true) { (session, authentication, completionCallback) -> Operation? in
            return session.getActivationRecovery(authentication: authentication) { data, error in
                resultData = data // we need to store the data for later use
                completionCallback(data, error)
            }
        }
        
        let operationExecutor = AuthenticationUIOperationExecutor(session: session, operation: operation, requestOptions: uiRequest.options, credentialsProvider: credentialsProvider)
        
        let process = AuthenticationUIProcess(session: session, uiProvider: uiAuthProvider, credentialsProvider: credentialsProvider, request: uiRequest, executor: operationExecutor)
        process.operationCompletion = { result, _, _, finalController in
            
            if result == .success, let data = resultData {
                
                let vc = uiRecoveryProvider.instantiateRecoveryController()
                vc.showCountdownDelay = false
                vc.setup(withData: data, uiProvider: uiRecoveryProvider, context: .standalone) { [weak vc] _ in
                    completion(.success, vc)
                }
                
                finalController?.navigationController?.pushViewController(vc, animated: true)
                
            } else {
                completion(result, finalController)
            }
        }
        
        let ui = LimeAuthAuthenticationUI(authenticationProcess: process)
        ui.entryScene = .enterPassword
        return ui
    }
}
