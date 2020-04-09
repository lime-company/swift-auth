//
// Copyright 2020 Wultra s.r.o.
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

open class AuthenticationOTPViewController: LimeAuthUIBaseViewController, ActivationUIProcessController {
    
    public var router: (ActivationUIProcessRouter & AuthenticationOTPRoutingLogic)?
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
        let router = AuthenticationOTPRouter()
        router.viewController = self
        viewController.router = router
    }
    
    deinit {
        unregisterForKeyboardNotifications()
    }
    
    // MARK: - View lifecycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        confirmButton?.isEnabled = false
        otpInput.addTarget(self, action: #selector(otpFieldDidChange), for: .editingChanged)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        registerForKeyboardNotifications()
        otpInput.becomeFirstResponder()
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
            D.fatalError("AuthenticationOTPViewController is not configured properly.")
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
    
    public func cancel() {
        router?.routeToPreviousScene()
    }
    
    public func confirm() {
        let otp = otpInput.text ?? ""
        let isValid = uiDataProvider.uiDataForAuthenticationOTP.validator?.validate(otp: otp) ?? !otp.isEmpty
        guard isValid else {
            let strings = uiDataProvider.uiDataForAuthenticationOTP.strings
            let alert = UIAlertController(title: strings.notValidAlertTitle, message: strings.notValidAlertText, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: strings.notValidAlertButton, style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        router?.routeToKeyExchange(otp: otp)
    }
    
    // MARK: - Keyboard handling
    
    var keyboardObserver: Any?
    
    private func registerForKeyboardNotifications() {
        if keyboardObserver != nil {
            return
        }
        keyboardObserver = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { [weak self] notification in
            guard let `self` = self else {
                return
            }
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
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
    
    // MARK: - Presentation
    
    @IBOutlet private weak var hintLabel: UILabel!
    @IBOutlet private weak var cancelButtonItem: UIBarButtonItem!
    @IBOutlet private weak var confirmButton: UIButton?
    @IBOutlet private weak var otpInput: UITextField!
    
    @IBOutlet private weak var bottomKeyboardConstraint: NSLayoutConstraint?
    
    var bottomSafeArea: CGFloat = 0.0

    var textFieldDefaultColor: UIColor?
    var textFieldBlinkColor: UIColor?
    
    // MARK: -
    
    open override func prepareUI() {
        let uiData = uiDataProvider.uiDataForAuthenticationOTP
        let commonStrings = uiDataProvider.uiCommonStrings
        let theme = uiDataProvider.uiTheme
        
        // Apply texts & images
        self.title = uiData.strings.sceneTitle
        hintLabel?.text = uiData.strings.sceneDescription
        confirmButton?.setTitle(uiData.strings.confirmButton, for: .normal)
        cancelButtonItem.title = commonStrings.cancelTitle
        otpInput.accessibilityLabel = uiData.strings.accessibilityInput

        // Apply themes
        
        // background should be clear color - no image
        configureBackground(image: nil, color: theme.common.backgroundColor)
        hintLabel?.textColor = theme.common.textColor
        confirmButton?.applyButtonStyle(theme.buttons.primary)
        otpInput.applyTextFieldStyle(theme.authOTP.otpCode)
        
    }
    
    @objc private func otpFieldDidChange() {
        confirmButton?.isEnabled = !(otpInput.text?.isEmpty ?? true)
    }
}
