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

import Foundation

public struct LimeAuthRecoveryUITheme {
    
    public struct RecoveryCodeScene {
        
        /// Screen title color
        public var titleColor: UIColor
        /// Normal text color
        public var textColor: UIColor
        /// Color for text displayed on the bottom of "recovery code" screen
        public var warningTextColor: UIColor
        /// Data header color (fot example for PUK header)
        public var headerTextColor: UIColor
        /// Color for activation code
        public var activationCodeColor: UIColor
        /// Color for PUK
        public var pukColor: UIColor
        
        /// Continue button
        public var continueButtonStyle: ButtonStyle
        
        /// How long (seconds) should be user unable to continue during activation
        public var activationContinueDelay: Int = 10
        /// If user should be informed that screenshots are bad in this case
        public var warnUserAboutScreenshot = true
        
        public init(
            titleColor: UIColor,
            textColor: UIColor,
            warningTextColor: UIColor,
            headerTextColor: UIColor,
            activationCodeColor: UIColor,
            pukColor: UIColor,
            errorTitleColor: UIColor,
            continueButtonStyle: ButtonStyle,
            skipButton: ButtonStyle,
            errorButton: ButtonStyle) {
            
            self.titleColor = titleColor
            self.textColor = textColor
            self.warningTextColor = warningTextColor
            self.headerTextColor = headerTextColor
            self.activationCodeColor = activationCodeColor
            self.pukColor = pukColor
            self.continueButtonStyle = continueButtonStyle
        }
    }
    
    public var recoveryScene: RecoveryCodeScene
    
    public init(recoveryScene: RecoveryCodeScene) {
        self.recoveryScene = recoveryScene
    }
}
