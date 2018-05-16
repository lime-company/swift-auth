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

/// The `LimeAuthActivationUITheme` structure defines colors, fonts and images used in the activation UI flow.
///
/// The theme is composed from several well separated sections:
/// * `Common` section defines various common attributes used in the activation screens
/// * `Illustrations` section defines illustrations used in the activation wizard
/// * `Images` section defines various additional images used in the activation wizard
/// * `Buttons` section defines styles for buttons used in the activation
/// * `ScannerScene` is a special section reserved for QR codes scanner screen
/// * `EnterCodeScene` is a special section reserved for activation code entering screen
/// * `NavigationBar` defines styling for navigation bar
///
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
        
        /// Status bar style applied to all activation scenes except QR code scanner.
        /// Note that your application has to support "ViewController based" status bar appearance.
        public var statusBarStyle: UIStatusBarStyle
        
        /// Structure initializer
        public init(
            backgroundColor: UIColor?,
            backgroundImage: LazyUIImage?,
            titleColor: UIColor,
            textColor: UIColor,
            highlightedTextColor: UIColor,
            activityIndicator: ActivityIndicatorStyle,
            keyboardAppearance: UIKeyboardAppearance,
            statusBarStyle: UIStatusBarStyle)
        {
            self.backgroundColor = backgroundColor
            self.backgroundImage = backgroundImage
            self.titleColor = titleColor
            self.textColor = textColor
            self.highlightedTextColor = highlightedTextColor
            self.activityIndicator = activityIndicator
            self.keyboardAppearance = keyboardAppearance
            self.statusBarStyle = statusBarStyle
        }
    }
    
    public struct Illustrations {
        /// Illustration at begin scene
        public var beginScene: LazyUIImage
        
        /// Illustration at "no camera access" scene. If empty, then `.errorScene` will be used
        public var noCameraScene: LazyUIImage
        
        /// Illustration at "enable biometry" scene
        public var enableBiometryScene: LazyUIImage
        
        /// Illustration at "waiting for activation confirmation" scene
        public var confirmScene: LazyUIImage
        
        /// Illustration at "error" scene
        public var errorScene: LazyUIImage
        
        /// Structure initializer
        public init(
            beginScene: LazyUIImage,
            noCameraScene: LazyUIImage,
            enableBiometryScene: LazyUIImage,
            confirmScene: LazyUIImage,
            errorScene: LazyUIImage)
        {
            self.beginScene = beginScene
            self.noCameraScene = noCameraScene
            self.enableBiometryScene = enableBiometryScene
            self.confirmScene = confirmScene
            self.errorScene = errorScene
        }
    }
    
    public struct Images {
        /// Crosshair used ar QR code scanner
        public var scannerCrosshair: LazyUIImage
        
        /// Structure initializer
        public init(
            scannerCrosshair: LazyUIImage)
        {
            self.scannerCrosshair = scannerCrosshair
        }
    }
    
    public struct Buttons {
        /// Button for primary action.
        /// This kind of button is typically instantiated as "custom".
        public var primary: ButtonStyle
        
        /// Button for secondary action
        /// This kind of button is typically instantiated as "custom".
        public var secondary: ButtonStyle
        
        /// Button for destructive action
        /// This kind of button is typically instantiated as "custom".
        public var destructive: ButtonStyle
        
        /// Button for cancel (small button at left top corner)
        /// This kind of button is typically instantiated as "system".
        public var cancel: ButtonStyle
        
        /// Structure initializer
        public init(
            primary: ButtonStyle,
            secondary: ButtonStyle,
            destructive: ButtonStyle,
            cancel: ButtonStyle)
        {
            self.primary = primary
            self.secondary = secondary
            self.destructive = destructive
            self.cancel = cancel
        }
    }
    
    public struct ScannerScene {
        /// Status bar style applied in scanner scene.
        /// Note that your application has to support "ViewController based" status bar appearance.
        public var statusBarStyle: UIStatusBarStyle
        
        /// Color for scanner's title text
        public var titleColor: UIColor
        
        /// Special close button
        public var closeButton: ButtonStyle
        
        /// Special fallback button
        public var fallbackButton: ButtonStyle
        
        /// Structure initializer
        public init(
            statusBarStyle: UIStatusBarStyle,
            titleColor: UIColor,
            closeButton: ButtonStyle,
            fallbackButton: ButtonStyle)
        {
            self.statusBarStyle = statusBarStyle
            self.titleColor = titleColor
            self.closeButton = closeButton
            self.fallbackButton = fallbackButton
        }
    }
    
    public struct EnterCodeScene {
        /// Style for text fields in "enter activation code" scene
        public var activationCode: TextFieldStyle
        
        /// Structure initializer
        public init(
            activationCode: TextFieldStyle)
        {
            self.activationCode = activationCode
        }
    }
    
    /// This section affects appearance of UINavigationBar & buttons, when it's visible.
    /// (typically in enter activation code scene)
    public struct NavigationBar {
        /// Background color for navigation bar
        public var backgroundColor: UIColor
        
        /// Color of title in navigation bar
        public var titleColor: UIColor
        
        /// General tint color, applied to navigation bar
        public var tintColor: UIColor
        
        /// Color of button in navigation bar
        public var buttonColor: UIColor
        
        /// Structure initializer
        public init(
            backgroundColor: UIColor,
            titleColor: UIColor,
            tintColor: UIColor,
            buttonColor: UIColor)
        {
            self.backgroundColor = backgroundColor
            self.titleColor = titleColor
            self.tintColor = tintColor
            self.buttonColor = buttonColor
        }
    }
    
    // MARK: - Theme content
    
    public var common: Common
    public var illustrations: Illustrations
    public var images: Images
    public var buttons: Buttons
    public var scannerScene: ScannerScene
    public var enterCodeScene: EnterCodeScene
    public var navigationBar: NavigationBar
    
    /// Theme initializer
    public init(
        common: Common,
        illustrations: Illustrations,
        images: Images,
        buttons: Buttons,
        scannerScene: ScannerScene,
        enterCodeScene: EnterCodeScene,
        navigationBar: NavigationBar)
    {
        self.common = common
        self.illustrations = illustrations
        self.images = images
        self.buttons = buttons
        self.scannerScene = scannerScene
        self.enterCodeScene = enterCodeScene
        self.navigationBar = navigationBar
    }
    
    /// Function provides a fallback theme used internally, for theme's initial values.
    public static func fallbackTheme() -> LimeAuthActivationUITheme {
        return LimeAuthActivationUITheme(
            common: Common(
                backgroundColor: .white,
                backgroundImage: nil,
                titleColor: .blue,
                textColor: .black,
                highlightedTextColor: .blue,
                activityIndicator: .small(.blue),
                keyboardAppearance: .default,
                statusBarStyle: .default
            ),
            illustrations: Illustrations(
                beginScene: .empty,
                noCameraScene: .empty,
                enableBiometryScene: .empty,
                confirmScene: .empty,
                errorScene: .empty
            ),
            images: Images(
                scannerCrosshair: .empty
            ),
            buttons: Buttons(
                primary: .noStyle,
                secondary: .noStyle,
                destructive: .noStyle,
                cancel: .noStyle
            ),
            scannerScene: ScannerScene(
                statusBarStyle: .default,
                titleColor: .white,
                closeButton: .noStyle,
                fallbackButton: .noStyle
            ),
            enterCodeScene: EnterCodeScene(
                activationCode: .noStyle
            ),
            navigationBar: NavigationBar(
                backgroundColor: .white,
                titleColor: .black,
                tintColor: .blue,
                buttonColor: .blue
            )
        )
    }
}

public extension LimeAuthActivationUITheme.Illustrations {
    
    /// Function makes all illustrations tinted with given color.
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

