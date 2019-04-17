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
}

class RecoveryDisplayView: UIView {
    
    private var continueButtonWait: Int = 10
    
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
    private lazy var codeFont = UIFont(name: "Menlo-Bold", size: 20)
    
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
        
        continueButtonWait = theme.recoveryScene.activationContinueDelay
        
        // Strings
        introTextLabel.text = strings.description
        codeHeaderLabel.text = strings.activationCodeHeader
        pukHeaderLabel.text = strings.pukHeader
        warningLabel.text = strings.warning
        continueString = strings.continueButton
        continueTimeString = strings.continueButtonWithSeconds
        
        // Font
        codeLabel.font = theme.recoveryScene.activationPukAndCodeFont ?? codeFont
        pukLabel.font = theme.recoveryScene.activationPukAndCodeFont ?? codeFont
        
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
