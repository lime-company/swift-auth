//
// Copyright 2017 Wultra s.r.o.
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

open class CreateFixedPasscodeViewController: LimeAuthUIBaseViewController, CreateAndVerifyPasswordRoutableController, PinKeyboardViewDelegate, PassphraseVerifying {
    
    public var router: (AuthenticationUIProcessRouter & CreateAndVerifyPasswordRoutingLogic)!
    public var uiDataProvider: AuthenticationUIDataProvider!
    
    var passphraseValidator: LimeAuthPassphraseValidator? {
        return router?.authenticationProcess?.credentialsValidator
    }
    
    private var actionFeedback: LimeAuthActionFeedback? {
        return router.authenticationProcess.uiProvider.actionFeedback
    }
    
    //
    
    public func canHandlePasswordCreation(for passwordType: LimeAuthCredentials.Password.PasswordType) -> Bool {
        return passwordType == .fixedPin
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
    @IBOutlet weak var pinKeyboard: PinKeyboardView!
    
    // Group of views for first password
    @IBOutlet weak var group1: UIView!              // grouping view
    @IBOutlet weak var prompt1Label: UILabel!       // prompt
    @IBOutlet weak var error1Label: UILabel!        // label for error, displayed when passwords doesn't match
    @IBOutlet weak var password1Label: UILabel!     // label for bullets
    
    // Group of views for second password
    @IBOutlet weak var group2: UIView!              // grouping view
    @IBOutlet weak var prompt2Label: UILabel!       // prompt (e.g. retype your pin)
    @IBOutlet weak var password2Label: UILabel!     // bullets
    
    // Constraint for movement animating
    @IBOutlet weak var groupsAnimationConstraint: NSLayoutConstraint!
    // Change complexity button
    @IBOutlet weak var changeComplexityButton: UIButton!
    // Success checkmark
    @IBOutlet weak var activityIndicator: (UIView & CheckmarkWithActivity)!
    
    // Layout adjustments
    @IBOutlet weak var pinKeyboardBottomConstraint: NSLayoutConstraint!
    
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
    private var password1 = ""
    /// Second password
    private var password2 = ""
    /// Complexity required for this PIN (initial value is invalid)
    private var requiredPasswordComplexity: LimeAuthCredentials.Password = .fixedPin(length: 0)
    /// Returns required lenght for this PIN
    private var requiredPasswordLength: Int {
        return self.requiredPasswordComplexity.minimumLength
    }
    /// Modifies whether complexity button is visible or not
    private var complexityButtonIsHidden = false
    
    // MARK: - ViewController life cycle
    
    private var isLoaded: Bool = false
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.isLoaded = true
        
        guard let _ = router?.authenticationProcess else {
            D.fatalError("CreateFixedPasscodeViewController is not configured properly")
        }
        
        complexityButtonIsHidden = router.authenticationProcess.credentialsProvider.credentials.passwordOptionsOrder.count <= 1
        updateLocalizedStrings()
        prepareUIForFirstUse()
        actionFeedback?.prepare()
    }
    
    // MARK: - Navigation
    
    private func doCancel() {
        if self.currentState == .firstPass {
            router.routeToCancel()
        } else if self.currentState == .secondPass {
            self.presentFirstGroup(animated: true, withError: false)
        }
    }
    
    private func doNext() {
        if self.currentState == .firstPass {
            self.presentSecondGroup()
        } else if self.currentState == .secondPass {
            if self.password1 == self.password2 {
                self.presentSuccess {
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
    
    // MARK: - Localizations
    
    open func updateLocalizedStrings() {
        //let commonStrings = uiDataProvider.uiCommonStrings
        let uiData = uiDataProvider.uiForCreateNewPassword
        
        self.prompt1Label.text = uiData.strings.enterNewPin
        self.prompt2Label.text = uiData.strings.retypePin
        self.error1Label.text = ""	// presentFirstGroup() updates this value
        
        self.changeComplexityButton.setTitle(uiData.strings.changeComplexityButton, for: .normal)
    }
    
    // MARK: - PIN keyboard view delegate
    
    open func pinKeyboardView(_ pinKeyboardView: PinKeyboardView, didTapOnDigit digit: Int) {
        self.appendDigit(digit)
    }
    
    open func pinKeyboardView(_ pinKeyboardView: PinKeyboardView, didTapOnSpecialKey key: PinKeyboardSpecialKey) {
        if key == .backspace {
            self.removeLastDigit()
        } else if key == .cancel {
            self.doCancel()
        }
    }
    
    open func pinKeyboardView(_ pinKeyboardView: PinKeyboardView, imageFor biometryIcon: PinKeyboardBiometryIcon) -> UIImage? {
        let uiTheme = uiDataProvider.uiTheme
        let lazyImage = biometryIcon == .touchID ? uiTheme.images.touchIdIcon : uiTheme.images.touchIdIcon
        return lazyImage.optionalImage
    }
    
    public func pinKeyboardViewActionFeedback(_ pinKeyboardView: PinKeyboardView) -> LimeAuthActionFeedback? {
        return actionFeedback
    }
    
    public func pinKeyboardView(_ pinKeyboardView: PinKeyboardView, accessibilityDescriptionFor icon: PinKeyboardSpecialKey) -> String? {
        switch icon {
        case .backspace: return uiDataProvider.uiCommonStrings.accessibilityRemoveLastChar
        case .biometry: return uiDataProvider.uiCommonStrings.accessibilityUseBiometry
        case .cancel: return uiDataProvider.uiCommonStrings.accessibilityCancel
        }
    }
   
    // MARK: - Private functions
    
    /// Length of current password (in characters)
    private var passwordLength: Int {
        if currentState == .firstPass {
            return password1.count
        } else if currentState == .secondPass {
            return password2.count
        }
        return 0
    }
    
    /// Allows update first or second password depending on which password is currently edited.
    /// The method also automatically calls `afterPasswordChange()` when the appropriate password is changed
    /// Block function should return true or false whether the password was edited or not
    private func updatePassword(block: (inout String)->Bool) {
        if currentState == .firstPass {
            let before = password1
            guard block(&password1) else {
                return
            }
            if before != password1 {
                afterPassowrdChange()
            }
        } else if currentState == .secondPass {
            let before = password2
            guard block(&password2) else {
                return
            }
            if before != password2 {
                afterPassowrdChange()
            }
        }
    }
    
    /// Appends digit to currently edited password
    private func appendDigit(_ digit: Int) {
        self.updatePassword { (p) in
            if p.count < self.requiredPasswordLength {
                p.append(Character(UnicodeScalar(48 + digit)!))
                return true
            } else {
                D.warning("Trying to add more digits than allowed")
                return false
            }
        }
    }
    
    /// Removes last digit from currently edited password
    private func removeLastDigit() {
        self.updatePassword { (p) in
            if !p.isEmpty {
                p.remove(at: p.index(before: p.endIndex))
                return true
            } else {
                D.warning("Removing digit from already empty password")
                return false
            }
        }
    }
    
    private func clearPassword()  {
        updatePassword { p in
            p.removeAll()
            return true
        }
    }
    
    /// Called after editing password is changed
    private func afterPassowrdChange() {
        self.updatePasswordLabel()
        let length = self.passwordLength
        if length == self.requiredPasswordLength {
            
            if currentState == .firstPass {
                
                // this will prompt user when pin is too weak and gives him option to pick different one
                verifyPassphrase(password1, type: .pin, uiDataProvider: uiDataProvider) { isOK in
                    // pin is OK or user want to use weak one
                    if isOK {
                        self.doNext()
                    } else {
                        _ = self.getAndResetPasswords()
                        self.updatePasswordLabel()
                    }
                }
            } else {
                doNext()
            }
            
        } else if length == 1 && self.currentState == .firstPass {
            // Hide error after first typed digit
            self.error1Label.text = ""
        }
    }
    
    /// Resets passwords to empty strings
    private func getAndResetPasswords() -> String {
        let password = self.password1
        let stars = String(repeating: "*", count: 2*self.requiredPasswordLength)
        self.password1.append(stars)
        self.password2.append(stars)
        self.password1.removeAll()
        self.password2.removeAll()
        return password
    }
    
    // MARK: - Update UI
    
    open func updatePasswordLabel() {
        let filledBulletsCount = self.passwordLength
        var bulletsText = String(repeating: "• ", count: filledBulletsCount)
        let emptyBulletsCount = self.requiredPasswordLength - filledBulletsCount
        if (emptyBulletsCount > 0) {
            bulletsText.append(String(repeating: "◦ ", count: emptyBulletsCount))
        }
        let currentLabel = self.currentState == .firstPass ? self.password1Label : self.password2Label
        currentLabel?.text = bulletsText
        // update backspace / cancel button
        let visibleBackspace = filledBulletsCount > 0
        let visibleCancel = !visibleBackspace && (self.currentState == .secondPass || !router.authenticationProcess.isPartOfActivation)
        self.pinKeyboard.setSpecialKeyVisible(.backspace, visible: visibleBackspace)
        self.pinKeyboard.setSpecialKeyVisible(.cancel, visible: visibleCancel)
        currentLabel?.accessibilityLabel = String(format: uiDataProvider.uiCommonStrings.accessibilityPinDisplay, filledBulletsCount, self.requiredPasswordLength)
    }
    
    //
    
    open func prepareUIForFirstUse() {
        // Apply styles
        let theme = uiDataProvider.uiTheme
        
        configureBackground(image: theme.common.backgroundImage, color: theme.common.backgroundColor)
        pinKeyboard?.applyButtonStyle(forDigits: theme.buttons.pinDigits, forAuxiliary: theme.buttons.pinAuxiliary)
        prompt1Label?.textColor = theme.common.promptTextColor
        prompt2Label?.textColor = theme.common.promptTextColor
        group1.backgroundColor = theme.common.topPartBackgroundColor
        group2.backgroundColor = theme.common.topPartBackgroundColor
        password1Label?.textColor = theme.common.passwordTextColor
        password1Label.font = UIFont.systemFont(ofSize: 40)
        password2Label?.textColor = theme.common.passwordTextColor
        password2Label.font = UIFont.systemFont(ofSize: 40)
        error1Label?.textColor = theme.common.highlightedTextColor
        (activityIndicator as? CheckmarkWithActivityView)?.applyIndicatorStyle(theme.styleForCheckmarkWithActivity)
        changeComplexityButton?.applyButtonStyle(theme.buttons.keyboardAuxiliary)

        // Configure controller
        self.pinKeyboard.delegate = self
        self.adjustLayout()
        self.presentFirstGroup(animated: false, withError: false)
    }
    
    /// Adjusts layout for various device screen sizes
    open func adjustLayout() {
        if LayoutHelper.phoneScreenSize == .small {
            // 5, 5s, SE
            self.pinKeyboardBottomConstraint?.constant = 12.0
        } else {
            // Other models
            self.pinKeyboardBottomConstraint?.constant = 32.0
        }
    }
    
    open func presentFirstGroup(animated: Bool, withError: Bool = false) {
        if !self.isLoaded {
            // not initialized yet. this happens when parent is switching this tab for first time
            return
        }
        // Update model
        let _ = self.getAndResetPasswords()
        self.currentState = .firstPass
        self.updatePasswordLabel()
        // Update views
        let duration = animated ? 0.2 : 0
		self.error1Label.text = withError ? uiDataProvider.uiForCreateNewPassword.strings.pinNoMatch : ""
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: {
            self.changeComplexityButton.alpha = self.complexityButtonIsHidden ? 0.0 : 1.0
            self.groupsAnimationConstraint.constant = 0.0
            self.view.layoutIfNeeded()
        }, completion: nil)
        
    }
    
    open func presentSecondGroup() {
        self.currentState = .secondPass
        self.updatePasswordLabel()
        
        UIView.animate(withDuration: 0.2, delay: 0.1, options: .curveEaseInOut, animations: {
            self.changeComplexityButton.alpha = 0
            self.groupsAnimationConstraint.constant = -self.view.frame.width
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    open func presentSuccess(completion: @escaping ()->Void) {
        self.currentState = .success
        
        actionFeedback?.scene(.operationSuccess)
        group1.layer.opacity = 0
        group2.layer.opacity = 0
        
        UIView.animate(withDuration: 0.2, delay: 0.1, options: .curveEaseInOut, animations: {
            self.groupsAnimationConstraint.constant = -2*self.view.frame.width
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        // we're delaying auto-navigation, so disable any tempering with potentional modal presentation
        setSwipeToDismissGestureEnabled(to: false) { resetBlock in
            self.activityIndicator.showSuccess(animated: true) {
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

