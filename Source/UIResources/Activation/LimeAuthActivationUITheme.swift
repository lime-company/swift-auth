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

import Foundation

public struct LimeAuthActivationUITheme {

    public struct Common {
        /// Common background color for all scenes.
        /// You can choose between `backgroundColor` or `backgroundImage`, or use both.
        public var backgroundColor: UIColor?
        
        /// Common background image for all scenes.
        /// You can choose between `backgroundColor` or `backgroundImage`, or use both.
        public var backgroundImage: LazyUIImage?
        
        /// Color for all scene titles
        public var titleColor: UIColor
        
        /// Color for all texts in scenes
        public var textColor: UIColor
        
        /// Color for all highlighted texts in scenes. This color is use for special texts, which has to
        /// be hightlighted to user.
        public var highlightedTextColor: UIColor
        
        /// Style applied to all activity indicators
        public var activityIndicator: ActivityIndicatorStyle
        
        /// Style used for system keyboards
        public var keyboardAppearance: UIKeyboardAppearance
    }
    
    public struct Illustrations {
        /// Illustration at begin scene
        public var beginScene: LazyUIImage
        
        /// Illustration at "no camera access" scene. If empty, then .errorScene will be used
        public var noCameraScene: LazyUIImage
        
        /// Illustration at "enable biometry" scene
        public var enableBiometryScene: LazyUIImage
        
        /// Illustration at "waiting for activation confirmation" scene
        public var confirmScene: LazyUIImage
        
        /// Illustration at "error" scene
        public var errorScene: LazyUIImage
    }
    
    public struct Images {
        /// Crosshair used ar QR code scanner
        public var scannerCrosshair: LazyUIImage
    }
    
    public struct Buttons {
        /// Button for primary action
        public var primary: ButtonStyle
        /// Button for secondary action
        public var secondary: ButtonStyle
        /// Button for destructive action
        public var destructive: ButtonStyle
        /// Button for cancel (small button at left top corner)
        public var cancel: ButtonStyle
    }
    
    public struct ScannerScene {
        /// Status bar style applied in scanner scene
        public var statusBarStyle: UIStatusBarStyle
        /// Color for scanner's title text
        public var titleColor: UIColor
        /// Special close button
        public var closeButton: ButtonStyle
        /// Special fallback button
        public var fallbackButton: ButtonStyle
    }
    
    // MARK: - Theme content
    
    public var common: Common
    public var illustrations: Illustrations
    public var images: Images
    public var buttons: Buttons
    public var scannerScene: ScannerScene
}

public extension LimeAuthActivationUITheme.Illustrations {
    
    /// Makes all illustrations tinted with given color.
    public func tinted(with color: UIColor) -> LimeAuthActivationUITheme.Illustrations {
        return LimeAuthActivationUITheme.Illustrations(
            beginScene: .tinted(beginScene, with: color),
            noCameraScene: .tinted(noCameraScene, with: color),
            enableBiometryScene: .tinted(enableBiometryScene, with: color),
            confirmScene: .tinted(confirmScene, with: color),
            errorScene: .tinted(errorScene, with: color)
        )
    }
}

