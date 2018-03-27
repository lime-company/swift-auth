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

public protocol CreateAndVerifyPasswordRoutingLogic: NewCredentialsRoutingLogic {
    func routeToChangeComplexity()
}

/// Protocol for controller designed for pick & verify one specific password type
public protocol CreateAndVerifyPasswordRoutableController: AuthenticationUIProcessController {
    
    func connectCreateAndVerifyPasswordRouter(router: AuthenticationUIProcessRouter & CreateAndVerifyPasswordRoutingLogic)
    
    func canHandlePasswordCreation(for passwordType: LimeAuthCredentials.Password.PasswordType) -> Bool
    func prepareForNewPassword(option: LimeAuthCredentials.Password)
}


public class CreateAndVerifyPasswordRouter: CreateAndVerifyPasswordRoutingLogic, AuthenticationUIProcessRouter {
    
    public var authenticationProcess: AuthenticationUIProcess!
    public weak var viewController: (UIViewController & CreateAndVerifyPasswordRoutableController)?
    
    // Specific for this type of router
    public typealias ParentRouterType = (NewCredentialsRoutingLogic & AuthenticationUIProcessRouter)
    private unowned let parentRouter: ParentRouterType
    
    private let changeComplexity: ()->Void
    private let beforeSuccess: (String)->Void
    
    init(parentRouter: ParentRouterType, changeComplexity: @escaping ()->Void, beforeSuccess: @escaping (String)->Void) {
        self.parentRouter = parentRouter
        self.changeComplexity = changeComplexity
        self.beforeSuccess = beforeSuccess
        self.authenticationProcess = parentRouter.authenticationProcess
    }
    
    public func connect(controller: AuthenticationUIProcessController) {
        viewController = controller as? (UIViewController & CreateAndVerifyPasswordRoutableController)
        assert(viewController != nil)
    }
    
    public func routeToCancel() {
        parentRouter.routeToCancel()
    }
    
    public func routeToSuccess(password: String) {
        beforeSuccess(password)
        parentRouter.routeToSuccess(password: password)
    }
    
    public func routeToError(error: LimeAuthError?) {
        parentRouter.routeToError(error: error)
    }
    
    public func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        parentRouter.prepare(for: segue, sender: sender)
    }
    
    public func routeToChangeComplexity() {
        changeComplexity()
    }
}
