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

@objc protocol RecoveryViewDelegate: class {
    func continueAction()
    func tryAgainAction()
    func laterAction()
}

class RecoveryDisplayView: UIView {
    
    private let continueButtonWait: Int = 10
    
    @IBOutlet private weak var introTextLabel: UILabel!
    @IBOutlet private weak var codeHeaderLabel: UILabel!
    @IBOutlet private weak var codeLabel: UILabel!
    @IBOutlet private weak var pukHeaderLabel: UILabel!
    @IBOutlet private weak var pukLabel: UILabel!
    @IBOutlet private weak var warningLabel: UILabel!
    @IBOutlet private weak var continueButton: UIButton!
    @IBOutlet private weak var delegate: RecoveryViewDelegate?
    
    private var stopWatch: UIStopWatch?
    private var continueString = ""
    private var continueTimeString = ""
    
    deinit {
        stopWatch?.stop()
    }
    
    func showRecoveryCode(_ data: LimeAuthRecoveryData, withWaitingCountdown: Bool) {
        codeLabel.text = data.activationCodeFormatted
        pukLabel.text = data.pukFormatted
        stopCountdown()
        continueButton.setTitle(continueString, for: .normal)
        if withWaitingCountdown {
            startCountdown()
        }
        isHidden = false
    }
    
    func hide() {
        isHidden = true
        stopCountdown()
    }
    
    func prepareUI(theme: LimeAuthRecoveryUITheme, strings: RecoveryCode.UIData.Strings) {
        
        // Strings
        introTextLabel.text = strings.description
        codeHeaderLabel.text = strings.activationCodeHeader
        pukHeaderLabel.text = strings.pukHeader
        warningLabel.text = strings.warning
        continueString = strings.continueButton
        continueTimeString = strings.continueButtonWithSeconds
        
        // Styles
        introTextLabel.textColor = theme.recoveryScene.textColor
        codeHeaderLabel.textColor = theme.recoveryScene.headerTextColor
        codeLabel.textColor = theme.recoveryScene.activationCodeColor
        pukHeaderLabel.textColor = theme.recoveryScene.headerTextColor
        pukLabel.textColor = theme.recoveryScene.pukColor
        warningLabel.textColor = theme.recoveryScene.warningTextColor
        continueButton.applyButtonStyle(theme.recoveryScene.continueButtonStyle)
    }
    
    @IBAction private func continueClicked(_ sender: UIButton) {
        delegate?.continueAction()
    }
    
    private func startCountdown() {
        
        guard stopWatch == nil else {
            return
        }
        
        continueButton.setTitle(String(format: continueTimeString, "\(continueButtonWait)"), for: .normal)
        continueButton.isEnabled = false
        
        stopWatch = UIStopWatch(dispatchInterval: 0.1)
        stopWatch?.start { [weak self] elapsed in
            guard let this = self else {
                return
            }
            let seconds = this.continueButtonWait - Int(elapsed)
            if seconds > 0 {
                this.continueButton.setTitle(String(format: this.continueTimeString, "\(seconds)"), for: .normal)
                this.continueButton.isEnabled = false
            } else {
                this.continueButton.setTitle(this.continueString, for: .normal)
                this.continueButton.isEnabled = true
                this.stopWatch?.stop()
                this.stopWatch = nil
            }
        }
    }
    
    private func stopCountdown() {
        stopWatch?.stop()
        stopWatch = nil
    }
}

class RecoveryErrorView: UIView {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var tryAgainButton: UIButton!
    @IBOutlet private weak var laterButton: UIButton!
    @IBOutlet private weak var delegate: RecoveryViewDelegate?
    
    func show() {
        isHidden = false
    }
    
    func hide() {
        isHidden = true
    }
    
    func prepareUI(theme: LimeAuthRecoveryUITheme, strings: RecoveryCode.UIData.Strings) {
        
        // Strings
        titleLabel.text = strings.errorTitle
        textLabel.text = strings.errorText
        tryAgainButton.setTitle(strings.retryButton, for: .normal)
        laterButton.setTitle(strings.skipButton, for: .normal)
        
        // Styles
        titleLabel.textColor = theme.recoveryScene.errorTitleColor
        textLabel.textColor = theme.recoveryScene.textColor
        tryAgainButton.applyButtonStyle(theme.recoveryScene.errorButton)
        laterButton.applyButtonStyle(theme.recoveryScene.skipButton)
    }
    
    @IBAction private func tryAgainClick(_ sender: UIButton) {
        delegate?.tryAgainAction()
    }
    
    @IBAction private func laterClick(_sender: UIButton) {
        delegate?.laterAction()
    }
}
