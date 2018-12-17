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

class VariablePinController: UIViewController, PasswordPresenterType {
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var labelContainer: UIView!
    @IBOutlet private weak var label: UILabel!
    @IBOutlet private weak var okButton: UIButton!
    
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
    
    // MARK: Private variables
    
    private let okPressedEvent: (() -> Void)
    
    private let minLength: Int
    private let maxLength: Int
    
    // MARK: - Lifecycle
    
    init(minLength: Int, maxLength: Int, bundle: Bundle? = nil, okClicked: @escaping () -> Void) {
        self.minLength = minLength
        self.maxLength = maxLength
        self.okPressedEvent = okClicked
        super.init(nibName: "VariablePinPresenter", bundle: bundle ?? Bundle(for: VariablePinController.self))
    }
    
    required init?(coder aDecoder: NSCoder) {
        D.fatalError("This should never be used from storyboards/nibs")
    }
    
    override func loadView() {
        super.loadView()
        applyState()
        applyStyle()
        applyStrings()
        showPassword(0)
    }
    
    // MARK: API
    
    func showPassword(_ passwordLength: Int) {
        
        guard passwordLength <= maxLength else {
            D.warning("trying to show passwordLenght bigger than maxLength")
            return
        }
        
        label?.text = String(repeating: "• ", count: passwordLength)
        
        okButton.isEnabled = passwordLength >= minLength && passwordLength <= maxLength
    }
    
    // MARK: IBActions
    
    @IBAction private func buttonClicked(_ button: UIButton) {
        okPressedEvent()
    }
    
    // MARK: Private functions
    
    private func applyState() {
        guard let theme = uiDataProvider?.uiTheme else {
            return
        }
        label?.textColor = errorState ? theme.common.wrongPasswordTextColor : theme.common.passwordTextColor
        
    }
    
    private func applyStyle() {
        guard let theme = uiDataProvider?.uiTheme else {
            return
        }
        okButton?.applyButtonStyle(theme.buttons.ok)
        labelContainer?.applyLayerStyle(theme.layerStyleFromAuthenticationCommon)
    }
    
    private func applyStrings() {
        guard let commonStrings = uiDataProvider?.uiCommonStrings else {
            return
        }
        okButton?.setTitle(commonStrings.okButton, for: .normal)
    }
}
