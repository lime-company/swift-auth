//
// Copyright 2019 Wultra s.r.o.
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

open class EnterCodeRecoveryViewController: LimeAuthUIBaseViewController, ActivationUIProcessController, ActivationCodeDelegate, PukViewDelegate {
    
    @IBOutlet weak var codeView: ActivationCodeView!
    @IBOutlet weak var pukView: PukView!
    @IBOutlet weak var confirmButton: PrimaryWizardButton!
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var pukLabel: UILabel!
    @IBOutlet weak var cancelButtonItem: UIBarButtonItem!
    @IBOutlet weak var bottomKeyboardConstraint: NSLayoutConstraint?
    @IBOutlet weak var stackView: UIStackView!
    
    public var router: (ActivationUIProcessRouter & EnterCodeRecoveryRoutingLogic)!
    public var uiDataProvider: ActivationUIDataProvider!
    
    private var bottomSafeArea: CGFloat = 0.0
    
    // MARK: - lifecycle
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        codeView.delegate = self
        pukView.delegate = self
        confirmButton.isEnabled = false
        if LayoutHelper.phoneScreenSize == .small || LayoutHelper.phoneScreenSize == .verySmall {
            stackView.spacing = 12
        } else {
            stackView.spacing = 20
        }
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
    
    open override func prepareUI() {
        
        let strings = uiDataProvider.uiDataForEnterCodeRecovery.strings
        let commonStrings = uiDataProvider.uiCommonStrings
        let theme = uiDataProvider.uiTheme
        
        title = strings.sceneTitle
        cancelButtonItem.title = commonStrings.cancelTitle
        codeLabel.text = strings.codeDescription
        pukLabel.text = strings.pukDescription
        confirmButton.setTitle(strings.confirmButton, for: .normal)
        
        configureBackground(image: nil, color: theme.common.backgroundColor)
        codeLabel.textColor = theme.common.textColor
        pukLabel.textColor = theme.common.textColor
        confirmButton?.applyButtonStyle(theme.buttons.primary)
        
        codeView.prepareComponent(uiDataProvider: uiDataProvider)
        pukView.prepareComponent(uiDataProvider: uiDataProvider)
    }
    
    // MARK: - routing
    
    open func connect(activationProcess process: ActivationUIProcess) {
        router?.activationProcess = process
        uiDataProvider = process.uiDataProvider
    }
    
    open override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        router?.prepare(for: segue, sender: sender)
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
    
    // MARK: - Actions
    
    @IBAction func continueAction(_ sender: UIButton) {
        let code = codeView.buildCode()
        let puk = pukView.buildPUK()
        router.routeToKeyExchange(activationCode: code, puk: puk)
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        router.routeToCancel()
    }
    
    // MARK: - Delegating
    
    public func pukChanged(puk: String) {
        validateInfo()
    }
    
    public func codeChanged(code: String) {
        validateInfo()
    }
    
    // MARK: - helpers
    
    private func setup() {
        let viewController = self
        let router = EnterCodeRecoveryRouter()
        router.viewController = self
        viewController.router = router
    }
    
    private func validateInfo() {
        let code = codeView.buildCode()
        let puk = pukView.buildPUK()
        confirmButton.isEnabled = PA2OtpUtil.validateRecoveryCode(code) && PA2OtpUtil.validateRecoveryPuk(puk)
    }
}
