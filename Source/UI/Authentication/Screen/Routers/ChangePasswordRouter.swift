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

public class EnterOldPasswordRouter: EnterPasswordRoutingLogic, AuthenticationUIProcessRouter {

    public weak var viewController: (UIViewController & AuthenticationUIProcessController)?
    public let authenticationProcess: AuthenticationUIProcess

    public init(authenticationProcess: AuthenticationUIProcess) {
        self.authenticationProcess = authenticationProcess
    }
    
    public func connect(controller: AuthenticationUIProcessController) {
        viewController = controller as? (UIViewController & AuthenticationUIProcessController)
        assert(viewController != nil)
    }
    
    public func routeToCancel() {
        authenticationProcess.cancelAuthentication(controller: viewController)
    }
    
    public func routeToSuccess() {
        
        guard let vc = viewController else {
            return
        }
        
        let router = NewCredentialsRouter(authenticationProcess: authenticationProcess)
        let nvc = authenticationProcess.uiProvider.instantiateNewCredentialsScene()
        vc.navigationController?.pushViewController(nvc, animated: true)
        nvc.connectCreatePasswordRouter(router: router)
        nvc.connect(authenticationProcess: authenticationProcess)
    }

    public func routeToError(error: LimeAuthError?) {
        authenticationProcess.failAuthentication(controller: viewController)
    }
}
