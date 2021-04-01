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

open class CreatePasswordViewController: LimeAuthUIBaseViewController, CreateAndVerifyPasswordRoutableController, UITextFieldDelegate, PassphraseVerifying {
    
    public var router: (AuthenticationUIProcessRouter & CreateAndVerifyPasswordRoutingLogic)!
    public var uiDataProvider: AuthenticationUIDataProvider!
    
    var passphraseValidator: LimeAuthPassphraseValidator? {
        return router?.authenticationProcess?.credentialsValidator
    }
    
    var actionFeedback: LimeAuthActionFeedback? {
        return router.authenticationProcess.uiProvider.actionFeedback
    }
    
    //
    
    public func canHandlePasswordCreation(for passwordType: LimeAuthCredentials.Password.PasswordType) -> Bool {
        return passwordType == .password
    }
    
    public func prepareForNewPassword(option: LimeAuthCredentials.Password) {
        requiredPasswordComplexity = option
        self.presentFirstGroup(animated: false, withError: false)
    }
    
    public func connectCreateAndVerifyPasswordRouter(router: AuthenticationUIProcessRouter & CreateAndVerifyPasswordRoutingLogic) {
        self.router = router
        router.connect(controller: self)
    }
    
    open func connect(authenticationProcess process: AuthenticationUIProcess) {
        router?.authenticationProcess = process
        process.currentRouter = router
        uiDataProvider = process.uiDataProvider
    }
    
    // MARK: - Outlets -
    
    // Group of views for first password
    @IBOutlet weak var group1: UIView!                    // grouping view
    @IBOutlet weak var prompt1Label: UILabel!            // prompt
    @IBOutlet weak var error1Label: UILabel!            // label for error, displayed when passwords doesn't match
    @IBOutlet weak var password1TextField: UITextField!    // label for bullets
    @IBOutlet weak var confirm1Button: UIButton!        // OK button
    @IBOutlet weak var roundCornersView1: UIView!   // View with round corners behind password
    
    // Group of views for first password
    @IBOutlet weak var group2: UIView!                    // grouping view
    @IBOutlet weak var prompt2Label: UILabel!            // prompt
    @IBOutlet weak var password2TextField: UITextField!    // label for bullets
    @IBOutlet weak var confirm2Button: UIButton!        // OK button
    @IBOutlet weak var roundCornersView2: UIView!   // View with round corners behind password
    
    // Constraint for movement animating
    @IBOutlet weak var groupsAnimationConstraint: NSLayoutConstraint!
    // Change complexity button
    @IBOutlet weak var changeComplexityButton: UIButton!
    /// A button for cancel
    @IBOutlet weak var cancelButton: UIButton!
    /// Keyboard accessory view
    @IBOutlet var keyboardAccessoryView: UIView!
    /// An activity indicator
    @IBOutlet weak var activityIndicator: (UIView & CheckmarkWithActivity)!
    
    // MARK: - Runtime variables
    
    private enum InterfaceState {
        case firstPass
        case secondPass
        case success
        case error
    }
    
    /// Current UI state.
    private var currentState     = InterfaceState.firstPass
    
    /// First password
    private var password1: String {
        return self.password1TextField.text ?? ""
    }
    /// Second password
    private var password2: String {
        return self.password2TextField.text ?? ""
    }
    
    /// Length of current password (in characters)
    private var passwordLength: Int {
        if self.currentState == .firstPass {
            return password1.count
        } else if currentState == .secondPass {
            return password2.count
        }
        return 0
    }
    
    private var activePasswordTextField: UITextField! {
        if self.currentState == .firstPass {
            return self.password1TextField
        } else if self.currentState == .secondPass {
            return self.password2TextField
        }
        return nil
    }
    
    /// Complexity required for this password (initial value is invalid)
    private var requiredPasswordComplexity: LimeAuthCredentials.Password = .alphanumeric(min: 0)
    
    /// Returns required lenght for this password
    private var minimumPasswordLength: Int {
        return self.requiredPasswordComplexity.minimumLength
    }
    
    /// Maximum length for the password. This is just a some safe limit, to do not allow to paste 65k strings,
    /// to the text field. Like the penetration testers do :)
    private let maximumPasswordLength: Int = 128
    
    /// Modifies whether complexity button is visible or not
    private var complexityButtonIsHidden = false
    
    // MARK: - ViewController life cycle
    
    private var isLoaded: Bool = false
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.isLoaded = true
        
        guard let _ = router?.authenticationProcess else {
            D.fatalError("CreatePasswordViewController is not configured properly")
        }
        
        complexityButtonIsHidden = router.authenticationProcess.credentialsProvider.credentials.passwordOptionsOrder.count <= 1
        updateLocalizedStrings()
        prepareUIForFirstUse()
        actionFeedback?.prepare()
    }
    
    
    // MARK: - Navigation
    
    private func doCancel() {
        self.activePasswordTextField?.resignFirstResponder()
        self.router.routeToCancel()
    }
    
    private func doNext() {
        // ignore "next" if password is too short
        if self.passwordLength < self.minimumPasswordLength {
            return
        }
        // switch state
        if self.currentState == .firstPass {
            self.presentSecondGroup()
        } else if self.currentState == .secondPass {
            if self.password1 == self.password2 {
                self.presentSuccess {
                    self.view.resignFirstResponder()
                    let password = self.getAndResetPasswords()
                    self.router.routeToSuccess(password: password)
                }
            } else {
                self.presentFailure {
                    self.presentFirstGroup(animated: true, withError: true)
                }
            }
        }
    }
    
    @IBAction private func passphraseSetupAction(_ sender: Any) {
        if self.currentState == .firstPass || self.currentState == .firstPass {
            router.routeToChangeComplexity()
        }
    }
    
    @IBAction private func confirmPasswordAction(_ sender: Any) {
        if currentState == .firstPass {
            
            // this will prompt user when password is too weak and gives him option to pick different one
            verifyPassphrase(password1, type: .password, uiDataProvider: uiDataProvider) { isOK in
                // password is OK or user want to use weak one
                if isOK {
                    self.doNext()
                } else {
                    _ = self.getAndResetPasswords()
                }
            }
        } else {
            doNext()
        }
    }
    
    @IBAction private func cancelAction(_ sender: Any) {
        self.doCancel()
    }
    
    /// Resets passwords to empty strings
    private func getAndResetPasswords() -> String {
        let password = self.password1
        self.password1TextField.text = nil
        self.password2TextField.text = nil
        return password
    }
    
    // MARK: - Localizations
    
    open func updateLocalizedStrings() {
        
        let commonStrings = uiDataProvider.uiCommonStrings
        let uiData = uiDataProvider.uiForCreateNewPassword
        
        self.prompt1Label.text = uiData.strings.enterNewPassword
        self.prompt2Label.text = uiData.strings.retypePassword
        self.error1Label.text = "" // presentFirstGroup() updates this value
		
        self.changeComplexityButton.setTitle(uiData.strings.changeComplexityButton, for: .normal)
        self.confirm1Button.setTitle(commonStrings.okButton, for: .normal)
        self.confirm2Button.setTitle(commonStrings.okButton, for: .normal)
        self.cancelButton.setTitle(commonStrings.cancelButton, for: .normal)
    }
    
    // MARK: - UITextFieldDelegate
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return textField == self.activePasswordTextField
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // paranoid test for a very big strings
        if string.count > self.maximumPasswordLength {
            return false
        }
        // calculate what will textfield contain after the update
        let currString = (textField.text ?? "") as NSString
        let nextString = currString.replacingCharacters(in: range, with: string)
        let shouldChange = nextString.count <= self.maximumPasswordLength
        if shouldChange {
            // update OK button, if change will be really applied
            self.updatePasswordConfirmButton(for: nextString)
        }
        return shouldChange
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.doNext()
        return false
    }
    
    // MARK: - Update UI
    
    open func updatePasswordConfirmButton(for nextPassword: String) {
        let enabled = nextPassword.count >= self.minimumPasswordLength
        let confirmButton = self.currentState == .firstPass ? self.confirm1Button : self.confirm2Button
        confirmButton?.isEnabled = enabled
    }
    
    //
    
    open func prepareUIForFirstUse() {
        // Apply styles
        let theme = uiDataProvider.uiTheme
        
        configureBackground(image: theme.common.backgroundImage, color: theme.common.backgroundColor)
        prompt1Label?.textColor = theme.common.promptTextColor
        prompt2Label?.textColor = theme.common.promptTextColor
        group1.backgroundColor = theme.common.topPartBackgroundColor
        group2.backgroundColor = theme.common.topPartBackgroundColor
        password1TextField?.applyTextFieldStyle(theme.common.passwordTextField)
        password1TextField?.font = UIFont.systemFont(ofSize: 17)
        password2TextField?.applyTextFieldStyle(theme.common.passwordTextField)
        password2TextField?.font = UIFont.systemFont(ofSize: 17)
        error1Label?.textColor = theme.common.highlightedTextColor
        confirm1Button?.applyButtonStyle(theme.buttons.ok)
        confirm2Button?.applyButtonStyle(theme.buttons.ok)
        roundCornersView1?.applyLayerStyle(theme.layerStyleFromAuthenticationCommon)
        roundCornersView2?.applyLayerStyle(theme.layerStyleFromAuthenticationCommon)
        
        (activityIndicator as? CheckmarkWithActivityView)?.applyIndicatorStyle(theme.styleForCheckmarkWithActivity)
        changeComplexityButton?.applyButtonStyle(theme.buttons.keyboardAuxiliary)
        
        // prepare text fields
        [ password1TextField!, password2TextField! ].forEach { (textField) in
            textField.delegate = self
            textField.isSecureTextEntry = true
            textField.inputAccessoryView = self.keyboardAccessoryView
            textField.clearButtonMode = .never
            (textField as? TextFieldWithInset)?.textContentInset = CGPoint(x: 12, y: 0)
        }
        password1TextField.returnKeyType = .next
        password1TextField.autocorrectionType = .no
        password2TextField.returnKeyType = .send
        password2TextField.autocorrectionType = .no
        
        // keep tint in accessory view
        self.keyboardAccessoryView.tintColor = self.view.tintColor
        // cancel
        self.cancelButton.isHidden = router.authenticationProcess.isPartOfActivation
        
        self.presentFirstGroup(animated: false, withError: false)
    }
    
    open func presentFirstGroup(animated: Bool, withError: Bool = false) {
        if !self.isLoaded {
            // not initialized yet. this happens when parent is switching this tab for first time
            return
        }
        // Update model
        let _ = self.getAndResetPasswords()
        self.currentState = .firstPass
        self.updatePasswordConfirmButton(for: "")
        self.password1TextField.becomeFirstResponder()
        
        // Update views
        let duration = animated ? 0.2 : 0
        self.error1Label.text = withError ? uiDataProvider.uiForCreateNewPassword.strings.passwordNoMatch : ""
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: {
            self.changeComplexityButton.alpha = 1
            self.groupsAnimationConstraint.constant = 0.0
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    open func presentSecondGroup() {
        self.currentState = .secondPass
        self.updatePasswordConfirmButton(for: "")
        self.password2TextField.becomeFirstResponder()
        
        UIView.animate(withDuration: 0.2, delay: 0.1, options: .curveEaseInOut, animations: {
            self.changeComplexityButton.alpha = 0
            self.groupsAnimationConstraint.constant = -self.view.frame.width
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    open func presentSuccess(completion: @escaping ()->Void) {
        self.currentState = .success
        
        actionFeedback?.scene(.operationSuccess)
        
        UIView.animate(withDuration: 0.2, delay: 0.1, options: .curveEaseInOut, animations: {
            self.groupsAnimationConstraint.constant = -2*self.view.frame.width
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        // we're delaying auto-navigation, so disable any tempering with potentional modal presentation
        setSwipeToDismissGestureEnabled(to: false) { resetBlock in
            self.activityIndicator.showSuccess {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
                    resetBlock()
                    completion()
                }
            }
        }
    }
    
    open func presentFailure(completion: @escaping ()->Void) {
        self.currentState = .error
        
        actionFeedback?.scene(.operationFail)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            completion()
        }
    }
    
}
