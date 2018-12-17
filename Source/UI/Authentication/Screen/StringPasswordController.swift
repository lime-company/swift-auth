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

/// Controller that displayes textfield for entering password.
class StringPasswordController: UIViewController, PasswordPresenterType, UITextFieldDelegate {
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var passwordContainer: UIView! // wrapper around textfield for styling purposes
    @IBOutlet private weak var passwordField: TextFieldWithInset! // editable password field
    @IBOutlet private weak var okButton: UIButton! // OK button for password confirmation
    
    // MARK: API variables
    
    var errorState = false {
        didSet {
            applyState()
        }
    }
    
    var uiDataProvider: AuthenticationUIDataProvider? {
        didSet {
            applyState()
            applyStyle()
            applyStrings()
        }
    }
    
    // MARK: Internal variables
    
    private let minimumPasswordLenth: Int
    
    /// Maximum length for the password. This is just a some safe limit, to do not allow to paste 65k strings,
    /// to the text field. Like the penetration testers do :)
    private let maximumPasswordLength = 128
    
    private let okPressedEvent: (() -> Void)
    private let passwordChangeEvent: ((String) -> Void)
    
    // MARK: - Lifecycle
    
    init(minimumPasswordLenth: Int, bundle: Bundle? = nil, passwordChanged: @escaping ((String) -> Void), okClicked: @escaping () -> Void) {
        self.passwordChangeEvent = passwordChanged
        self.okPressedEvent = okClicked
        self.minimumPasswordLenth = minimumPasswordLenth
        super.init(nibName: "StringPasswordPresenter", bundle: bundle ?? Bundle(for: StringPasswordController.self))
    }
    
    required init?(coder aDecoder: NSCoder) {
        D.fatalError("This should never be used from storyboards/nibs")
    }
    
    override func loadView() {
        super.loadView()
        passwordField.delegate = self
        applyState()
        applyStyle()
        applyStrings()
        showPassword(0)
    }
    
    // MARK: - API
    
    func showPassword(_ passwordLength: Int) {
        
        guard passwordLength == 0 else {
            return
        }
        
        passwordField.text = ""
        okButton.isEnabled = false
    }
    
    func focusField() {
        passwordField.becomeFirstResponder()
    }
    
    func defocusField() {
        passwordField.resignFirstResponder()
    }
    
    // MARK: - IBActions
    
    @IBAction private func buttonClicked(_ button: UIButton) {
        confirm()
    }
    
    // MARK: UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // paranoid test for a very big strings
        if string.count > maximumPasswordLength {
            return false
        }
        // calculate what will textfield contain after the update
        let currString = (textField.text ?? "") as NSString
        let nextString = currString.replacingCharacters(in: range, with: string)
        let shouldChange = nextString.count <= self.maximumPasswordLength
        if shouldChange {
            okButton.isEnabled = nextString.count >= minimumPasswordLenth
            passwordChangeEvent(nextString as String)
        }
        return shouldChange
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        confirm()
        return false
    }
    
    // MARK: - Internal functionality
    
    private func confirm() {
        guard let text = passwordField.text, text.count >= minimumPasswordLenth else {
            return
        }
        okPressedEvent()
    }
    
    private func applyState() {
        guard let theme = uiDataProvider?.uiTheme else {
            return
        }
        passwordField?.textColor = errorState ? theme.common.wrongPasswordTextColor : theme.common.passwordTextColor
    }
    
    private func applyStyle() {
        guard let theme = uiDataProvider?.uiTheme else {
            return
        }
        okButton?.applyButtonStyle(theme.buttons.ok)
        passwordContainer?.applyLayerStyle(theme.layerStyleFromAuthenticationCommon)
    }
    
    private func applyStrings() {
        guard let commonStrings = uiDataProvider?.uiCommonStrings else {
            return
        }
        okButton?.setTitle(commonStrings.okButton, for: .normal)
    }
}
