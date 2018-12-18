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

/// Reciever of Passphrase display events
protocol PassphraseDisplayDelegate: class {
    /// OK button was tapped
    func passphraseDisplay(confirmPassword: String)
    /// When first or second displayed is showed
    func passphraseDisplay(isConfirmMode: Bool)
    /// Cancel button was tapped
    func passphraseDisplayCancel()
    /// Biometry button was tapped
    func passphraseDisplayBiometry()
    /// When passwords don't match (in confirm mode)
    func passphraseDisplayConfirmFailed()
    /// For some input types, custom keyboard is requested
    func passphraseDisplayGetKeyboard() -> PinKeyboardController
}

// MARK: - Main controller class

/// Controller what will display password input/display based on the password type
class PassphraseDisplayController: UIViewController, PinKeyboardDelegate, PasscodeDelegate {
    
    private var keyboard: PinKeyboardController? {
        didSet {
            keyboard?.delegate = self
            refreshKeyboardSpecial()
        }
    }
    
    // MARK: API variables
    
    var actionFeedback: LimeAuthActionFeedback?
    
    /// Text that will be displayed above passphrase field
    var promptText = "" { didSet { promptLabel?.text = promptText } }
    /// Text that will be displayed above passphrase field in confirm mode
    var cofirmPromptText = "" { didSet { confirmPromptLabel?.text = cofirmPromptText } }
    
    // MARK: IBOutles
    
    @IBOutlet private weak var promptLabel: UILabel!
    @IBOutlet private weak var presenterContainer: UIView!
    @IBOutlet private weak var errorLabel: UILabel!
    @IBOutlet private weak var leadingConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var confirmPromptLabel: UILabel!
    @IBOutlet private weak var confirmpresenterContainer: UIView!
    
    // MARK: Private vars
    
    private unowned var delegate: PassphraseDisplayDelegate
    
    private var presenter: PasswordPresenterType!
    private var passcode: Passcode!
    
    private var confirmPresenter: PasswordPresenterType?
    private var confirmPasscode: Passcode?
    
    private let uiDataProvider: AuthenticationUIDataProvider
    private let credentials: LimeAuthCredentials.Password
    
    private let confirmPasswordMode: Bool
    private let biometryAllowed: Bool
    
    private var confirmDisplayed = false
    
    /// Creates instance of PassPhrase display
    ///
    /// - Parameters:
    ///   - credentials: type of credentials that will be presented
    ///   - uiDataProvider: data provider
    ///   - confirmPassword: if password should be confirmed (entering password 2x)
    ///   - allowBiometry: if biometry should be allowed
    ///   - delegate: delegate that will take action
    init(bundle: Bundle?, credentials: LimeAuthCredentials.Password, uiDataProvider: AuthenticationUIDataProvider, confirmPassword: Bool, allowBiometry: Bool, delegate: PassphraseDisplayDelegate) {
        
        self.biometryAllowed = allowBiometry
        self.confirmPasswordMode = confirmPassword
        self.uiDataProvider = uiDataProvider
        self.credentials = credentials
        self.delegate = delegate
        
        passcode = Passcode(credentials: credentials)
        if confirmPassword {
            confirmPasscode = Passcode(credentials: credentials)
        }
        
        super.init(nibName: "PassphraseDisplay", bundle: bundle ?? Bundle(for: PassphraseDisplayController.self))
        
        switch credentials.type {
        case .fixedPin:
            presenter = FixedPinController(length: passcode.maxLength, bundle: bundle)
            if confirmPassword {
                confirmPresenter = FixedPinController(length: passcode.maxLength, bundle: bundle)
            }
            getKeyboard()
        case .variablePin:
            presenter = VariablePinController(minLength: passcode.minLength, maxLength: passcode.maxLength, bundle: bundle) { [weak self] in
                guard let this = self else {
                    return
                }
                if this.confirmPasswordMode {
                    this.displayConfirm(true)
                } else {
                    this.delegate.passphraseDisplay(confirmPassword: this.passcode.value)
                }
            }
            if confirmPassword {
                confirmPresenter = VariablePinController(minLength: passcode.minLength, maxLength: passcode.maxLength, bundle: bundle) { [weak self] in
                    self?.comparePasswords()
                }
            }
            getKeyboard()
        case .password:
            presenter = StringPasswordController(
                minimumPasswordLenth: passcode.minLength,
                bundle: bundle,
                passwordChanged: { [weak self] password in
                    self?.passcode.set(to: password)
                    if password.isEmpty == false {
                        self?.clearError()
                    }
                },
                okClicked: { [weak self] in
                    guard let this = self else {
                        return
                    }
                    if this.confirmPasswordMode {
                        this.displayConfirm(true)
                    } else {
                        this.delegate.passphraseDisplay(confirmPassword: this.passcode.value)
                    }
                }
            )
            if confirmPassword {
                confirmPresenter = StringPasswordController(
                    minimumPasswordLenth: passcode.minLength,
                    passwordChanged: { [weak self] password in
                        self?.confirmPasscode?.set(to: password)
                    },
                    okClicked: { [weak self] in
                        self?.comparePasswords()
                    }
                )
            }
            
        }
        
        presenter.uiDataProvider = uiDataProvider
        confirmPresenter?.uiDataProvider = uiDataProvider
        
        passcode.delegate = self
        confirmPasscode?.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.view.translatesAutoresizingMaskIntoConstraints = false
        presenterContainer.addSubview(presenter.view)
        presenterContainer.fillWithSubview(presenter.view)
        
        if let confirmPresenter = confirmPresenter {
            confirmPresenter.view.translatesAutoresizingMaskIntoConstraints = false
            confirmpresenterContainer.addSubview(confirmPresenter.view)
            confirmpresenterContainer.fillWithSubview(confirmPresenter.view)
        }
        
        promptLabel.text = promptText
        confirmPromptLabel.text = cofirmPromptText
        
        promptLabel.textColor = uiDataProvider.uiTheme.common.promptTextColor
        confirmPromptLabel.textColor = uiDataProvider.uiTheme.common.promptTextColor
        errorLabel.textColor = uiDataProvider.uiTheme.common.highlightedTextColor
    }
    
    /// Clears input fields and displays first password group
    func resetPassword() {
        displayConfirm(false)
        passcode.clear()
        confirmPasscode?.clear()
    }
    
    /// Shows error (in first input field if confirm mode)
    func showError(_ errorText: String) {
        errorLabel?.text = errorText
        displayConfirm(false)
    }
    
    /// Sets error label to empty string
    func clearError() {
        errorLabel?.text = ""
    }
    
    /// Focuces currently displayed field (for popping the keyboard if necesarry)
    func focusField() {
        if confirmDisplayed {
            confirmPresenter?.focusField()
        } else {
            presenter.focusField()
        }
    }
    
    /// Defocuses currently displayed field (for hiding the keyboard if necesarry)
    func defocusField() {
        presenter?.defocusField()
        confirmPresenter?.defocusField()
    }
    
    /// Will shake the input field with error state
    func shake(time: TimeInterval = 0.07, completion: (() -> Void)? = nil) {
        
        guard let viewForShake = presenter.view else {
            return
        }
        
        UIView.animate(withDuration: time, delay: 0, options: .curveEaseOut, animations: {
            viewForShake.transform = CGAffineTransform.init(translationX: -10.0, y: 0.0)
            self.presenter.errorState = true
            self.view.layoutIfNeeded()
        }) { _ in
            UIView.animate(withDuration: time * 2, delay: 0, options: .curveEaseInOut, animations: {
                viewForShake.transform = CGAffineTransform.init(translationX: 10.0, y: 0.0)
                self.view.layoutIfNeeded()
            }) { _ in
                UIView.animate(withDuration: time, delay: 0, options: .curveEaseIn, animations: {
                    viewForShake.transform = CGAffineTransform.identity
                    self.view.layoutIfNeeded()
                }) { _ in
                    self.presenter.errorState = false
                    completion?()
                }
            }
        }
    }
    
    // MARK: Helper methods
    
    private func getKeyboard() {
        keyboard = delegate.passphraseDisplayGetKeyboard()
        keyboard?.delegate = self
        refreshKeyboardSpecial()
    }
    
    private func comparePasswords() {
        if passcode.value == confirmPasscode?.value {
            delegate.passphraseDisplay(confirmPassword: passcode.value)
        } else {
            delegate.passphraseDisplayConfirmFailed()
        }
    }
    
    private func displayConfirm(_ value: Bool, animate: Bool = true, delay: Bool = false) {
        
        guard confirmDisplayed != value else {
            return
        }
        confirmDisplayed = value
        let changeTo = confirmDisplayed ? -view.frame.width : 0
        UIView.animate(withDuration: animate ? 0.25 : 0, delay: delay ? 0.1 : 0, options: [], animations: {
            self.leadingConstraint.constant = changeTo
            self.view.layoutIfNeeded()
        }, completion: nil)
        refreshKeyboardSpecial()
        focusField()
        delegate.passphraseDisplay(isConfirmMode: confirmDisplayed)
    }
    
    private func refreshKeyboardSpecial() {
        var length: Int
        if confirmDisplayed {
            length = confirmPasscode!.length
        } else {
            length = passcode.length
        }
        
        keyboard?.setSpecialKeyVisible(.biometry, visible: !confirmPasswordMode && biometryAllowed)
        keyboard?.setSpecialKeyVisible(.cancel, visible: length == 0)
        keyboard?.setSpecialKeyVisible(.backspace, visible: length != 0)
    }
    
    // MARK: Passcode delegate
    
    fileprivate func passcodeChanged(sender: Passcode) {
        if sender === passcode {
            presenter.showPassword(sender.length)
            
            if sender.type == .fixedPin && sender.hasMaxLength {
                
                if confirmPasswordMode {
                    // delay the action little bit to display "full bullets"
                    displayConfirm(true, animate: true, delay: true)
                } else {
                    delegate.passphraseDisplay(confirmPassword: sender.value)
                }
            }
            
        } else if sender === confirmPasscode {
            confirmPresenter?.showPassword(sender.length)
            
            if sender.type == .fixedPin && sender.hasMaxLength {
                
                comparePasswords()
            }
        }
        refreshKeyboardSpecial()
    }
    
    // MARK: Pin keyboard delegate
    
    func pinKeyboard(_ sender: PinKeyboardController, didTapDigit digit: Int) {
        
        clearError()
        var playFeedback = false
        
        if confirmDisplayed {
            playFeedback = confirmPasscode!.append(digit: digit)
        } else {
            playFeedback = passcode.append(digit: digit)
        }
        
        if playFeedback {
            actionFeedback?.scene(.digitKeyPressed)
        }
    }
    
    func pinKeyboard(_ sender: PinKeyboardController, didTapSpecialKey key: PinKeyboardSpecialKey) {
        
        clearError()
        
        if key == .cancel {
            if confirmDisplayed {
                passcode.clear()
                displayConfirm(false)
            } else {
                delegate.passphraseDisplayCancel()
            }
        } else if key == .backspace {
            
            if confirmDisplayed {
                confirmPasscode?.removeLastChar()
            } else {
                passcode.removeLastChar()
            }
            
        } else if key == .biometry {
            delegate.passphraseDisplayBiometry()
        }
        actionFeedback?.scene(.specialKeyPressed)
    }
    
    func pinKeyboard(_ sender: PinKeyboardController, imageFor biometryIcon: PinKeyboardBiometryIcon) -> UIImage? {
        let lazyImage = biometryIcon == .touchID ? uiDataProvider.uiTheme.images.touchIdIcon : uiDataProvider.uiTheme.images.faceIdIcon
        return lazyImage.optionalImage
    }
}

// MARK: - Passcode class.

/// Passcode is private class to hold and manipulate with password string instead of just depending on textields
fileprivate class Passcode {
    
    weak var delegate: PasscodeDelegate?
    
    let minLength: Int
    let maxLength: Int
    let type: LimeAuthCredentials.Password.PasswordType
    var length: Int { return value.count }
    var hasMinLength: Bool { return length >= minLength }
    var hasMaxLength: Bool { return length >= maxLength }
    
    private(set) var value = ""
    
    init(credentials: LimeAuthCredentials.Password) {
        minLength = credentials.minimumLength
        maxLength = credentials.maximumLength
        type = credentials.type
    }
    
    @discardableResult func append(digit: Int) -> Bool {
        guard length < maxLength else {
            return false
        }
        
        value.append(Character(UnicodeScalar(48 + digit)!))
        delegate?.passcodeChanged(sender: self)
        return true
    }
    
    func set(to value: String) {
        self.value = value
        delegate?.passcodeChanged(sender: self)
    }
    
    func removeLastChar() {
        guard value.isEmpty == false else {
            return
        }
        value.removeLast()
        delegate?.passcodeChanged(sender: self)
    }
    
    func clear() {
        value.removeAll()
        delegate?.passcodeChanged(sender: self)
    }
}

private protocol PasscodeDelegate: class {
    func passcodeChanged(sender: Passcode)
}
