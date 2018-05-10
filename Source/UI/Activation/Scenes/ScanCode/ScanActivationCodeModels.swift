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

public enum ScanActivationCode {
    
    public struct UIData {
        
        public struct Strings {
            let sceneTitle: String
            let enterCodeFallbackButton: String
        }
        
        public struct Images {
            var crossHair: LazyUIImage
        }
        
        public struct Style {
            var statusBarStyle: UIStatusBarStyle
            var promptColor: UIColor
            var fallbackButton: ButtonStyle?
            var closeButton: ButtonStyle?
        }
        
        public var strings: Strings
        public var images: Images
        public var style: Style
        
        public static func fallbackData() -> UIData {
            let strings = Strings(
                sceneTitle: "Scan the activation QR code",
                enterCodeFallbackButton:  "Unsuccessful? Rewrite the code."
            )
            let images = Images(crossHair: .empty)
            let style = Style(
                statusBarStyle: .default,
                promptColor: .white,
                fallbackButton: nil,
                closeButton: nil
            )
            return UIData(strings: strings, images: images, style: style)
        }
        
    }
}
