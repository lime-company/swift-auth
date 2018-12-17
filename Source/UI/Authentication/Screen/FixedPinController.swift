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

/// Controller that will present pin label - [• • • •]
/// Use
class FixedPinController: UIViewController, PasswordPresenterType {
    
    @IBOutlet private weak var label: UILabel!
    
    var errorState = false {
        didSet {
            applyState()
        }
    }
    
    var uiDataProvider: AuthenticationUIDataProvider? {
        didSet {
            applyState()
        }
    }
    
    private let length: Int
    
    init(length: Int, bundle: Bundle? = nil) {
        self.length = length
        super.init(nibName: "FixedPinPresenter", bundle: bundle ?? Bundle(for: FixedPinController.self))
    }
    
    required init?(coder aDecoder: NSCoder) {
        D.fatalError("Shouldnt be instantiated from nib")
    }
    
    override func loadView() {
        super.loadView()
        applyState()
        showPassword(0) // set initial state
    }
    
    func showPassword(_ passwordLength: Int) {
        
        guard passwordLength <= length else {
            D.warning("trying to show passwordLenght bigger than maxLength")
            return
        }
        
        var bulletsText = String(repeating: "• ", count: passwordLength)
        let emptyBulletsCount = length - passwordLength
        if emptyBulletsCount > 0 {
            bulletsText.append(String(repeating: "◦ ", count: emptyBulletsCount))
        }
        
        label?.text = bulletsText
    }
    
    private func applyState() {
        guard let theme = uiDataProvider?.uiTheme else {
            return
        }
        
        label?.textColor = errorState ? theme.common.wrongPasswordTextColor : theme.common.passwordTextColor
    }
}
