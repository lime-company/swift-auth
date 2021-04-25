//
// Copyright 2021 Wultra s.r.o.
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

extension UILabel {
    
    func showPinDots(filled: Int, totalLength: Int, uiDataProvider: AuthenticationUIDataProvider) {
        let text = String(repeating: "• ", count: filled) + String(repeating: "◦ ", count: totalLength - filled)
        let atrStr = NSMutableAttributedString(string: text, attributes: [NSAttributedString.Key.font: font!])
        
        if filled > 0 {
            atrStr.addAttribute(.foregroundColor, value: uiDataProvider.uiTheme.common.filledPinDotColor, range: NSRange(location: 0, length: filled * 2))
        }
        
        if filled != totalLength {
            atrStr.addAttribute(.foregroundColor, value: uiDataProvider.uiTheme.common.emptyPinDotColor, range: NSRange(location: filled * 2, length: (totalLength - filled) * 2))
        }
        
        attributedText = atrStr
    }
}
