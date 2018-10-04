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

open class NewCredentialsViewController: UITabBarController, NewCredentialsRoutableController {
    
    public var router: (AuthenticationUIProcessRouter & NewCredentialsRoutingLogic)!
    public var uiDataProvider: AuthenticationUIDataProvider!
    
    // MARK: - Object lifecycle
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        let viewController = self
        viewController.connectCreatePasswordRouter(router: NewCredentialsRouter())
    }
    
    // MARK: - View lifecycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        // Check controller's setup
        guard let _ = router?.authenticationProcess else {
            fatalError("NewCredentialsViewController is not configured properly")
        }
        
        // Hide tabbar
        self.tabBar.isHidden = true
        //
        self.prepareTabMapping()
    }
    
    
    // MARK: - Routing
    
    public func connectCreatePasswordRouter(router: AuthenticationUIProcessRouter & NewCredentialsRoutingLogic) {
        self.router = router
        router.connect(controller: self)
    }
    
    public func connect(authenticationProcess process: AuthenticationUIProcess) {
        router?.authenticationProcess = process
        uiDataProvider = process.uiDataProvider
    }
    
    open override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        router?.prepare(for: segue, sender: sender)
    }
    
    
    // MARK: - Password options
    
    /// Contains mapping from type of passphrase to tab in tabbar
    private var typeToTabMapping = [LimeAuthCredentials.Password.PasswordType: Int]()
    
    /// Contains last selected password complexity or nil, if it was not changed.
    private var selectedPasswordComplexityIndex: Int?
    
    /// Child router...
    private var routerForChildren: (CreateAndVerifyPasswordRoutingLogic & AuthenticationUIProcessRouter)!
    
    /// Prepares `typeToTabMapping` property and all embedded controllers.
    private func prepareTabMapping() {
        // get provider
        let credentialsProvider = router.authenticationProcess.credentialsProvider
        // prepare router for children
        routerForChildren = CreateAndVerifyPasswordRouter(
            parentRouter: router,
            changeComplexity: { [weak self] in
                // Called when child controllers wants to change complexity
                if let `self` = self {
                    self.showSelectionWithPasswordComplexities()
                }
                //
            }, beforeSuccess: { [weak self] (password) in
                // Called before parent router is completed with password
                if let `self` = self {
                    let credentials = Authentication.UICredentials(password: password, optionsIndex: self.selectedPasswordComplexityIndex)
                    self.router.authenticationProcess.storeNextCredentials(credentials: credentials)
                }
                //
        })
        
        // Match controller to passwor type
        let allTabs = self.viewControllers ?? []
        self.typeToTabMapping.removeAll()
        var availableTypes: [LimeAuthCredentials.Password.PasswordType] = [ .fixedPin, .variablePin, .password ]
        for (tabIndex, controller) in allTabs.enumerated() {
            if let picker = controller as? CreateAndVerifyPasswordRoutableController {
                picker.connectCreateAndVerifyPasswordRouter(router: routerForChildren)
                picker.connect(authenticationProcess: router.authenticationProcess)
                for (typeIndex, type) in availableTypes.enumerated() {
                    if picker.canHandlePasswordCreation(for: type) {
                        availableTypes.remove(at: typeIndex)
                        self.typeToTabMapping[type] = tabIndex
                        break
                    }
                }
            }
        }
        // Change tab to current password
        self.changeComplexity(to: credentialsProvider.credentials.password, optionIndex: nil)
    }
    
    private func changeComplexity(to option: LimeAuthCredentials.Password, optionIndex: Int?) {
        guard let index = self.typeToTabMapping[option.type] else {
            D.warning("NewCredentialsViewController: Password type '\(option.type)' is not handled in UI.")
            return
        }
        guard let picker = self.viewControllers?[index] as? CreateAndVerifyPasswordRoutableController else {
            D.warning("NewCredentialsViewController: Tab at index \(index) doesn't implement CreateAndVerifyPasswordRoutableController.")
            return
        }
        picker.prepareForNewPassword(option: option)
        selectedIndex = index
        if let optionIndex = optionIndex {
            self.selectedPasswordComplexityIndex = optionIndex
        }
    }
    
    private func showSelectionWithPasswordComplexities() {
        // get required data
        let uiData = uiDataProvider.uiForCreateNewPassword
        let uiCommonStrings = uiDataProvider.uiCommonStrings
        
        let credentialsProvider = router.authenticationProcess.credentialsProvider
        
        // Build an action sheet
        let actionSheet = UIAlertController(title: uiData.strings.changeComplexityTitle, message: nil, preferredStyle: .actionSheet)
        // Add all options to action sheet
        let credentials = credentialsProvider.credentials
        for optionIndex in credentials.passwordOptionsOrder {
            let option = credentials.passwordOptions[optionIndex]
            let title  = uiDataProvider.localizePasswordComplexity(option: option)
            actionSheet.addAction(UIAlertAction(title: title, style: .default) { (action) in
                self.changeComplexity(to: option, optionIndex: optionIndex)
            })
        }
        
        // add cancel to action sheet
        actionSheet.addAction(UIAlertAction(title: uiCommonStrings.cancelButton, style: .cancel, handler: nil))
        // Present action sheet
        self.present(actionSheet, animated: true, completion: nil)
    }
}
