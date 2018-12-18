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

/// General-purpose controller that servers for displaying password/PIN and keyboard.
/// Make sure you connect this controller via EnterPasswordRoutableController or NewCredentialsRoutableController methods before displaying
class PassphraseScreenController: LimeAuthUIBaseViewController, EnterPasswordRoutableController, NewCredentialsRoutableController, PassphraseScreenPresenter, PassphraseDisplayDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var complexityButton: UIButton!
    @IBOutlet private weak var keyboardView: UIView!
    @IBOutlet private weak var pinView: UIView!
    @IBOutlet private weak var activityIndicator: CheckmarkWithActivityView!
    
    @IBOutlet private weak var bottomKeyboardConstraint: NSLayoutConstraint!
    @IBOutlet private weak var pinViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var complexityButtonBottomConstraint: NSLayoutConstraint!
    
    // MARK: - Private variables
    
    private var model: PassphraseScreenModel! // model that provides core functionality to this controller (created based on router)
    private var router: PassphraseScreenRouter! // routing logic provided by caller of this controller
    private var uiDataProvider: AuthenticationUIDataProvider! // ui data provided by caller
    private var strings: Strings! // class that holds strings
    
    private var uiRequest: Authentication.UIRequest? { return router.authenticationProcess.uiRequest }
    private var actionFeedback: LimeAuthActionFeedback? { return router.authenticationProcess.uiProvider.actionFeedback }
    
    private var keyboardController: PinKeyboardController?
    private var passphraseController: PassphraseDisplayController!
    
    private var complexityButtonBottomConstraintDefault: CGFloat = 12
    
    // only show cancel button for string password (due to actual system  keyboard insted of custom one)
    private var cancelButtonHidden: Bool = false {
        didSet {
            cancelButton.isHidden = cancelButtonHidden ? true : !(model.credentialsType.type == .password)
        }
    }
    
    // complexity is available only when creating/changing password
    private var complexityButtonHidden: Bool = false {
        didSet {
            complexityButton.isHidden = complexityButtonHidden ? true : !(model.operationType == .createPassword)
        }
    }
    
    // MARK: - Lifecycle events
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if uiRequest?.tweaks.presentedAsModal == true || uiRequest?.tweaks.hideNavigationBar == true {
            navigationController?.setNavigationBarHidden(true, animated: animated)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        complexityButtonBottomConstraintDefault = complexityButtonBottomConstraint.constant
    }
    
    // MARK: - IBActions
    
    // cancel button clicked (we should dismiss the flow)
    @IBAction private func cancelClicked(_ button: UIButton) {
        cancel()
    }
    
    @IBAction private func complexityClicked(_ button: UIButton) {
        showSelectionWithPasswordComplexities()
    }
    
    // MARK: - PassphraseScreenPresenter implementation
    
    /// Implementation of PassphraseScreenModel's presenter. this is  how model communicate with this controller
    func presentState(_ newState: PassphraseScreenModel.State, completion: (() -> Void)?) {
        
        assert(Thread.isMainThread)
        
        view.layer.removeAllAnimations()
        
        switch newState {
        case .enterPassword(let animated):
            showEnterPasswordState(animated: animated, completion: completion)
        case .activity(let animated):
            showLoadingState(animated: animated, completion: completion)
        case .error(let result):
            showErrorState(message: strings.errorMessage(fromResult: result), completion: completion)
        case .success(let animated):
            showSuccessState(animated: animated, completion: completion)
        case .initial:
            break // nothing to display
        }
    }
    
    // MARK: - Core private functionality
    
    /// This is essetial method - setups all necesarry components and model.
    private func setup(credentialsType: LimeAuthCredentials.Password, credentialsIndex: Int) {
        
        let isCreatingNewPassword = router is NewCredentialsRoutingLogic
        let isFirstUse = model == nil
        
        model = PassphraseScreenModel(router: router, operation: isCreatingNewPassword ? .createPassword : .authorize, credentialsType: credentialsType, credentialsIndex: credentialsIndex, parent: self)
        strings = Strings(provider: uiDataProvider, type: model.credentialsType.type, prompts: uiRequest?.prompts, creatingCredentials: isCreatingNewPassword)
        
        let theme = uiDataProvider.uiTheme
        
        if view == nil {
            loadView()
        }
        
        if isFirstUse {
            view.tintColor = UIColor.rgb(0x777777) // TODO: moved from storyboard to code. This should be stylable
            configureBackground(image: theme.common.backgroundImage, color: theme.common.backgroundColor)
            activityIndicator.applyIndicatorStyle(theme.styleForCheckmarkWithActivity)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        }
        
        keyboardView.subviews.forEach { $0.removeFromSuperview() }
        pinView.subviews.forEach { $0.removeFromSuperview() }
        keyboardController = nil
        passphraseController = nil
        
        switch model.credentialsType.type {
        case .fixedPin, .variablePin:
            cancelButtonHidden = true
        case .password:
            cancelButtonHidden = false
            cancelButton.setTitle(uiDataProvider.uiCommonStrings.cancelButton, for: .normal)
        }
        
        pinView.layer.opacity = 0
        let displayControl = PassphraseDisplayController(bundle: nibBundle, credentials: model.credentialsType, uiDataProvider: uiDataProvider, confirmPassword: isCreatingNewPassword, allowBiometry: model.isBiometryAllowed, delegate: self)
        pinView.addSubview(displayControl.view)
        displayControl.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            displayControl.view.trailingAnchor.constraint(equalTo: pinView.trailingAnchor, constant: 0),
            displayControl.view.leadingAnchor.constraint(equalTo: pinView.leadingAnchor, constant: 0),
            displayControl.view.centerYAnchor.constraint(equalTo: pinView.centerYAnchor, constant: 0)
        ])
        pinView.layoutIfNeeded()
        pinView.layer.opacity = 1
        displayControl.actionFeedback = actionFeedback
        passphraseController = displayControl
        actionFeedback?.prepare()
        complexityButtonHidden = !isCreatingNewPassword
        complexityButton.setTitle(uiDataProvider.uiForCreateNewPassword.strings.changeComplexityButton, for: .normal)
        complexityButton.applyButtonStyle(theme.buttons.keyboardAuxiliary)
        
        model.startModel()
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
            actionSheet.addAction(UIAlertAction(title: title, style: .default) { _ in
                self.setup(credentialsType: option, credentialsIndex: optionIndex)
            })
        }
        
        // add cancel to action sheet
        actionSheet.addAction(UIAlertAction(title: uiCommonStrings.cancelButton, style: .cancel, handler: nil))
        // Present action sheet
        present(actionSheet, animated: true, completion: nil)
    }
    
    private func showEnterPasswordState(animated: Bool, completion: (()->Void)? = nil) {
        
        passphraseController?.resetPassword()
        passphraseController?.showError(strings.remainingsAttemptsMessage(failedAttempts: model.failAttempts, remainingAttempts: model.remainingAttempts))
        passphraseController?.promptText = strings.prompt
        passphraseController?.cofirmPromptText = strings.confirmPrompt
        cancelButtonHidden = false
        complexityButtonHidden = false
        
        UIView.animate(withDuration: animated ? 0.25 : 0, delay: 0, options: .curveEaseInOut, animations: {
            //
            self.activityIndicator.alpha = 0
            self.activityIndicator.showIdle(animated: animated)
            self.keyboardView.transform = CGAffineTransform.identity
            self.keyboardView.alpha = 1.0
            //
            self.view.layoutIfNeeded()
        }) { [weak self] _ in
            self?.passphraseController?.focusField()
            completion?()
        }
    }
    
    private func showLoadingState(animated: Bool, completion: (()->Void)? = nil) {
        
        cancelButtonHidden = true
        complexityButtonHidden = true
        passphraseController?.defocusField()
        UIView.animate(withDuration: animated ? 0.25 : 0, delay: 0, options: .curveEaseInOut, animations: {
            //
            self.activityIndicator.alpha = 1
            self.activityIndicator.showActivity(animated: animated)
            let yShift = self.keyboardView.frame.size.height + LayoutHelper.bezellesPhoneSafeArea.bottom + self.bottomKeyboardConstraint.constant
            self.keyboardView.transform = CGAffineTransform.init(translationX: 0.0, y: yShift)
            self.keyboardView.alpha = 0.3
            //
            self.view.layoutIfNeeded()
        }) { _ in
            completion?()
        }
    }
    
    private func showSuccessState(animated: Bool, completion: (()->Void)? = nil) {
        
        cancelButtonHidden = true
        complexityButtonHidden = true
        passphraseController?.defocusField()
        passphraseController?.promptText = strings.successMessage
        passphraseController?.cofirmPromptText = strings.successMessage
        passphraseController?.clearError()
        actionFeedback?.scene(.operationSuccess)
        UIView.animate(withDuration: animated ? 0.25 : 0, delay: 0, options: .curveEaseInOut, animations: {
            //
            self.activityIndicator.alpha = 1
            self.activityIndicator.showSuccess(animated: animated)
            let yShift = self.keyboardView.frame.size.height + LayoutHelper.bezellesPhoneSafeArea.bottom + self.bottomKeyboardConstraint.constant
            self.keyboardView.transform = CGAffineTransform.init(translationX: 0.0, y: yShift)
            self.keyboardView.alpha = 0.3
            //
            self.view.layoutIfNeeded()
        }) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(self.uiRequest?.tweaks.successAnimationDelay ?? 0)) {
                completion?()
            }
        }
    }
    
    private func showErrorState(message: String, completion: (()->Void)? = nil) {
        
        cancelButtonHidden = true
        complexityButtonHidden = true
        passphraseController?.defocusField()
        passphraseController?.resetPassword()
        activityIndicator.showError()
        passphraseController?.promptText = message
        actionFeedback?.scene(.operationFail)
        
        passphraseController?.shake {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(self.uiRequest?.tweaks.errorAnimationDelay ?? 0)) {
                completion?()
            }
        }
    }
    
    private func cancel() {
        passphraseController?.defocusField()
        model.navigateToCancel()
    }
    
    // MARK: - System keyboard Events
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        let keyboardFrame = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        let viewPosition = complexityButton.convert(complexityButton.frame.origin, to: nil)
        
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut, animations: {
            self.complexityButtonBottomConstraint.constant = keyboardFrame.cgRectValue.origin.y - viewPosition.y + self.complexityButtonBottomConstraintDefault
            self.view.layoutIfNeeded()
        })
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut, animations: {
            self.complexityButtonBottomConstraint.constant = self.complexityButtonBottomConstraintDefault
            self.view.layoutIfNeeded()
        })
    }
    
    // MARK: - Passphrase display delegate
    
    // Maximum length for pin was hit or OK button was tapped
    func passphraseDisplay(confirmPassword: String) {
        model.confirm(withPassword: confirmPassword)
    }
    
    // User clicked cancel (on custom keyboard)
    func passphraseDisplayCancel() {
        model.navigateToCancel()
    }
    
    // User clicked biometry button (on custom keyboard)
    func passphraseDisplayBiometry() {
        model.confirmWithBiometry()
    }
    
    // User entered wrong password for verification of the first one (when creating/changing)
    func passphraseDisplayConfirmFailed() {
        passphraseController?.shake()
        actionFeedback?.scene(.operationFail)
        passphraseController?.resetPassword()
        passphraseController?.showError(strings.notSame)
    }
    
    // Switched to "confirm" mode when creating/changing password
    func passphraseDisplay(isConfirmMode: Bool) {
        complexityButtonHidden = isConfirmMode
    }
    
    // Password type of "PIN" requires special keyboard
    func passphraseDisplayGetKeyboard() -> PinKeyboardController {
        
        let keyboard = PinKeyboardController.create()
        keyboard.view.translatesAutoresizingMaskIntoConstraints = false
        bottomKeyboardConstraint.constant = LayoutHelper.phoneScreenSize == .small ? 12 : 32
        keyboardView.addSubview(keyboard.view)
        keyboardView.fillWithSubview(keyboard.view)
        
        keyboard.applyButtonStyle(forDigits: uiDataProvider.uiTheme.buttons.pinDigits, forAuxiliary: uiDataProvider.uiTheme.buttons.pinAuxiliary)
        
        keyboardController = keyboard
        return keyboard
    }
    
    // MARK: Routing protocol implementation
    
    func connectCreatePasswordRouter(router: AuthenticationUIProcessRouter & NewCredentialsRoutingLogic) {
        self.router = router
        router.connect(controller: self)
    }
    
    func connectEnterPasswordRouter(router: (AuthenticationUIProcessRouter & EnterPasswordRoutingLogic)) {
        self.router = router
        router.connect(controller: self)
    }
    
    func connect(authenticationProcess process: AuthenticationUIProcess) {
        uiDataProvider = process.uiDataProvider
        setup(credentialsType: router.authenticationProcess.credentialsProvider.credentials.password, credentialsIndex: router.authenticationProcess.credentialsProvider.credentials.passwordIndex)
    }
}

/// Strings for PassphraseScreenController
private class Strings {
    
    let prompt: String
    let successMessage: String
    let confirmPrompt: String
    let notSame: String
    
    private let provider: AuthenticationUIDataProvider
    private let prompts: Authentication.UIRequest.Prompts?
    private let creatingCredentials: Bool
    
    init(provider: AuthenticationUIDataProvider, type: LimeAuthCredentials.Password.PasswordType, prompts: Authentication.UIRequest.Prompts?, creatingCredentials: Bool) {
        
        let isPin = type != .password
        
        self.creatingCredentials = creatingCredentials
        self.provider = provider
        self.prompts = prompts
        
        if creatingCredentials {
            notSame = provider.uiForCreateNewPassword.strings.pinNoMatch
            prompt = isPin ? provider.uiForCreateNewPassword.strings.enterNewPin : provider.uiForCreateNewPassword.strings.enterNewPassword
            confirmPrompt = isPin ? provider.uiForCreateNewPassword.strings.retypePin : provider.uiForCreateNewPassword.strings.retypePassword
            successMessage = ""
        } else {
            prompt = prompts?.keyboardPrompt ?? (isPin ? provider.uiCommonStrings.enterPin : provider.uiCommonStrings.enterPassword)
            successMessage = prompts?.successMessage ?? provider.uiCommonStrings.success
            confirmPrompt = ""
            notSame = ""
        }
    }
    
    func remainingsAttemptsMessage(failedAttempts: UInt32, remainingAttempts: UInt32) -> String {
        return failedAttempts > 0 ? provider.localizeRemainingAttempts(attempts: remainingAttempts) : ""
    }
    
    func errorMessage(fromResult result: AuthenticationUIOperationResult) -> String {
        
        var message: String
        
        if result.isAuthenticationError {
            if result.isActivationProblem {
                if result.activationState == .blocked {
                    message = provider.uiCommonErrors.activationIsBlocked
                } else if result.activationState == .removed {
                    message = provider.uiCommonErrors.activationWasRemoved
                }
            }
            message = provider.uiCommonErrors.wrongPin
        } else {
            message = provider.localizeError(error: result.error, fallback: prompts?.errorFallbackMessage ?? provider.uiCommonStrings.failure)
        }
        
        return message
    }
}
