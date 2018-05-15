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

import UIKit
import PowerAuth2

open class EnterActivationCodeViewController: LimeAuthUIBaseViewController, ActivationUIProcessController, UITextFieldDelegate {

    public var router: (ActivationUIProcessRouter & EnterActivationCodeRoutingLogic)?
    public var uiDataProvider: ActivationUIDataProvider!
    
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
        let router = EnterActivationCodeRouter()
        router.viewController = self
        viewController.router = router
    }
    
    deinit {
        unregisterForKeyboardNotifications()
    }
    
    // MARK: - View lifecycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        registerForKeyboardNotifications()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        unregisterForKeyboardNotifications()
        self.view.resignFirstResponder()
    }
    
    open override func viewSafeAreaInsetsDidChange() {
        if #available(iOS 11.0, *) {
            super.viewSafeAreaInsetsDidChange()
            self.bottomSafeArea = view.safeAreaInsets.bottom
        }
    }
    
    open override func configureController() {
        guard let _ = router?.activationProcess else {
            fatalError("EnterActivationCodeViewController is not configured properly.")
        }
    }
    
    // MARK: - Routing
    
    open func connect(activationProcess process: ActivationUIProcess) {
        router?.activationProcess = process
        uiDataProvider = process.uiDataProvider
    }
    
    open override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        router?.prepare(for: segue, sender: sender)
    }
    
    
    // MARK: - Interactions
    
    @IBAction func cancelAction(_ sender: Any) {
        cancel()
    }
    
    @IBAction func confirmAction(_ sender: Any) {
        confirm()
    }
    
    @IBAction func textFieldDidChange() {
        // handle enabling and disabling even on delete
        let _ = enableOrDisableNextActions()
    }
    
    public func cancel() {
        router?.routeToPreviousScene()
    }
    
    public func confirm() {
        let code = buildCode()
        if !validateCode(code: code) {
            return
        }
        router?.routeToKeyExchange(activationCode: code)
    }
    
    // MARK: - Keyboard handling
    
    var keyboardObserver: Any?
    
    private func registerForKeyboardNotifications() {
        if keyboardObserver != nil {
            return
        }
        keyboardObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillShow, object: nil, queue: .main) { [weak self] (notification) in
            guard let `self` = self else {
                return
            }
            if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                let keyboardHeight = keyboardRectangle.height - self.bottomSafeArea + 20.0
                self.bottomKeyboardConstraint?.constant = keyboardHeight
            }
        }
    }

    private func unregisterForKeyboardNotifications() {
        if let observer = keyboardObserver {
            NotificationCenter.default.removeObserver(observer)
            keyboardObserver = nil
        }
    }
    
    public func buildCode() -> String {
        var code = ""
        code += textField1?.text ?? ""
        code += "-"
        code += textField2?.text ?? ""
        code += "-"
        code += textField3?.text ?? ""
        code += "-"
        code += textField4?.text ?? ""
        return code
    }
    
    public func validateCode(code: String) -> Bool {
        return PA2OtpUtil.validateActivationCode(code)
    }
    
    public func validateAndCorrectCharacters(_ string: String) -> (Bool, String) {
        var result : String = ""
        var success = true
        for codepoint in string.unicodeScalars {
            let newCodepoint = PA2OtpUtil.validateAndCorrectTypedCharacter(codepoint.value)
            if newCodepoint != 0 {
                let corrected = UnicodeScalar(newCodepoint)!
                result.append(Character(corrected))
            } else {
                success = false
                break
            }
        }
        return (success, result)
    }
    
    public var isEmptyCode: Bool {
        return textField1?.text?.isEmpty ?? true &&
                textField2?.text?.isEmpty ?? true &&
                textField3?.text?.isEmpty ?? true &&
                textField4?.text?.isEmpty ?? true
    }

    // MARK: -
    
    public func textField(_ tf: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let segmentLength = 5
        
        if tf == textField1 && isEmptyCode && range.location == 0 && validateCode(code: string) {
            pasteFullCode(code:string)
            return false
        }
        // check delete
        if string.isEmpty && range.length > 0 {
            return true
        }
        let (validChar, correctedString) = validateAndCorrectCharacters(string)
        if !validChar {
            if string != "-" {
                // character is not dash, we can blink with the text field
                errorBlink(textField: tf)
            }
            return false
        }
        
        let currString = (tf.text ?? "") as NSString
        let nextString = currString.replacingCharacters(in: range, with: correctedString)
        
        let oldLength = tf.text?.lengthOfBytes(using: .ascii) ?? 0
        let newLength = correctedString.lengthOfBytes(using: .ascii)
        
        if oldLength + newLength <= segmentLength {
            tf.text = nextString
            if oldLength + newLength == segmentLength {
                focusNextTextField(current: tf)
            }
            if let position = tf.position(from: tf.endOfDocument, offset: 0) {
                tf.selectedTextRange = tf.textRange(from: position, to: position)
            }
            // nothing to focus, try to check code
            let _ = enableOrDisableNextActions()
        }
        return false
    }
    
    public func focusNextTextField(current: UITextField) {
        var next: UITextField?
        if current == textField1 {
            next = textField2;
        } else if current == textField2 {
            next = textField3
        } else if current == textField3 {
            next = textField4
        }
        if let focusNext = next {
            focusNext.becomeFirstResponder()
            if let position = focusNext.position(from: focusNext.endOfDocument, offset: 0) {
                focusNext.selectedTextRange = focusNext.textRange(from: position, to: position)
            }
        }
    }
    
    public func pasteFullCode(code: String) {
        // full code pasted to the first field
        let components = code.components(separatedBy: "-")
        textField1?.text = components[0]
        textField2?.text = components[1]
        textField3?.text = components[2]
        textField4?.text = components[3]
        // new cursor position
        if let tf = textField4 {
            if let position = tf.position(from: tf.endOfDocument, offset: 0) {
                tf.selectedTextRange = tf.textRange(from: position, to: position)
            }
        }
        textField1?.resignFirstResponder()
        let _ = enableOrDisableNextActions()
    }
    
    open func errorBlink(textField: UITextField) {
        // TODO: implement blink
    }
    
    open func enableOrDisableNextActions() -> Bool {
        let enable = validateCode(code: buildCode())
        confirmButton?.isEnabled = enable
        return enable
    }
    
    // MARK: - Presentation
    
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var cancelButtonItem: UIBarButtonItem!
    @IBOutlet weak var textField1: UITextField?
    @IBOutlet weak var textField2: UITextField?
    @IBOutlet weak var textField3: UITextField?
    @IBOutlet weak var textField4: UITextField?
    @IBOutlet weak var confirmButton: UIButton?
    
    @IBOutlet weak var bottomKeyboardConstraint: NSLayoutConstraint?
    
    var bottomSafeArea: CGFloat = 0.0

    var textFieldDefaultColor: UIColor?
    var textFieldBlinkColor: UIColor?
    
    // MARK: -
    
    open override func prepareUI() {
        let uiData = uiDataProvider.uiDataForEnterActivationCode
        let commonStrings = uiDataProvider.uiCommonStrings
        let theme = uiDataProvider.uiTheme
        
        // Apply texts & images
        self.title = uiData.strings.sceneTitle
        hintLabel?.text = uiData.strings.sceneDescription
        confirmButton?.setTitle(uiData.strings.confirmButton, for: .normal)
        cancelButtonItem.title = commonStrings.cancelTitle

        // Apply themes
        configureBackground(image: theme.common.backgroundImage, color: theme.common.backgroundColor)
        hintLabel?.textColor = theme.common.titleColor
        confirmButton?.applyButtonStyle(theme.buttons.primary)
        
        // Prepare text fields
        prepareTextFields()
        if let tf1 = textField1, let tf2 = textField2, let tf3 = textField3, let tf4 = textField4 {
            for textField in [ tf1, tf2, tf3, tf4 ] {
                textField.applyTextFieldStyle(theme.enterCodeScene.activationCode)
            }
        }
    }
    
    open func prepareTextFields() {
        
        guard let tf1 = textField1, let tf2 = textField2, let tf3 = textField3, let tf4 = textField4 else {
            return
        }
        
        // FIXME: UI constants in code
        
        textFieldDefaultColor = tf1.textColor ?? UIColor.black
        textFieldBlinkColor = UIColor.red
        
        let bigScreen = UIScreen.main.bounds.width > 320.0
        let textInset = CGPoint(x: bigScreen ? 8 : 4, y:0)
        let font = UIFont(name: "CourierNewPSMT", size: bigScreen ? 18 : 14)
        
        for textField in [ tf1, tf2, tf3, tf4 ] {
            textField.text = ""
            textField.delegate = self
            textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
            textField.font = font
            if let insetTextField = textField as? TextFieldWithInset {
                insetTextField.textContentInset = textInset
            }
        }
        
        let _ = enableOrDisableNextActions()
        textField1?.becomeFirstResponder()
    }
}
