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

import UIKit

/// The `LimeAuthAuthenticationUITheme` structure defines color, fonts, images and other visual aspects
/// in the authentication UI flow.
///
/// The theme is composed from several well separated sections:
/// * `Common` section defines various common attributes used in the screens
/// * `Images` section defines images used in the screens
/// * `Buttons` section defines styles for buttons used in the screens
///
public struct LimeAuthAuthenticationUITheme {
    
    public struct Common {
        /// Common background color for all authentication scenes.
        /// You can choose between `backgroundColor` or `backgroundImage`, or use both.
        public var backgroundColor: UIColor?
        
        public var topPartBackgroundColor: UIColor?
        
        /// Common background image for all authentication scenes.
        /// You can choose between `backgroundColor` or `backgroundImage`, or use both.
        public var backgroundImage: LazyUIImage?
        
        /// Color for all prompts in authentication scenes (e.g. "Enter your PIN").
        public var promptTextColor: UIColor
        
        /// Highlighted color for "remaining attempts" error, or for errors related to creating a new password.
        public var highlightedTextColor: UIColor
        
        /// Color for password label or text field.
        public var passwordTextColor: UIColor
        
        /// Color temporariliy presented to password label (or text field) when user enters a wrong PIN.
        public var wrongPasswordTextColor: UIColor
        
        /// Style applied to all activity indicators
        public var activityIndicator: ActivityIndicatorStyle
        
        /// Style for password text field
        public var passwordTextField: TextFieldStyle
        
        /// Border width around password field and OK button
        public var passwordBorderWidth: CGFloat
        
        /// Border color around password field and OK button
        public var passwordBorderColor: UIColor?
        
        /// Border corner radius around password field and OK button
        public var passwordBorderCornerRadius: CGFloat
        
        /// Status bar style for all authentication scenes.
        /// Note that your application has to support "ViewController based" status bar appearance.
        public var statusBarStyle: UIStatusBarStyle
        
        /// Structure initializer
        public init(
            backgroundColor: UIColor?,
            topPartBackgroundColor: UIColor?,
            backgroundImage: LazyUIImage?,
            promptTextColor: UIColor,
            highlightedTextColor: UIColor,
            passwordTextColor: UIColor,
            wrongPasswordTextColor: UIColor,
            activityIndicator: ActivityIndicatorStyle,
            passwordTextField: TextFieldStyle,
            passwordBorderWidth: CGFloat,
            passwordBorderColor: UIColor?,
            passwordBorderCornerRadius: CGFloat,
            statusBarStyle: UIStatusBarStyle)
        {
            self.backgroundColor = backgroundColor
            self.topPartBackgroundColor = topPartBackgroundColor
            self.backgroundImage = backgroundImage
            self.promptTextColor = promptTextColor
            self.highlightedTextColor = highlightedTextColor
            self.passwordTextColor = passwordTextColor
            self.wrongPasswordTextColor = wrongPasswordTextColor
            self.activityIndicator = activityIndicator
            self.passwordTextField = passwordTextField
            self.statusBarStyle = statusBarStyle
            self.passwordBorderWidth = passwordBorderWidth
            self.passwordBorderColor = passwordBorderColor
            self.passwordBorderCornerRadius = passwordBorderCornerRadius
        }
    }
    
    public struct Images {
        /// Logo displayed in pin keyboards
        public var logo: LazyUIImage?
        
        /// Image displayed when entered password is correct
        public var successImage: LazyUIImage
        
        /// Image displayed in case of error
        public var failureImage: LazyUIImage
        
        /// Touch ID icon for PIN keyboard's biometry button
        public var touchIdIcon: LazyUIImage
        
        /// Face ID icon for PIN keyboard's biometry button
        public var faceIdIcon: LazyUIImage
        
        /// Structure initializer
        public init(
            logo: LazyUIImage?,
            successImage: LazyUIImage,
            failureImage: LazyUIImage,
            touchIdIcon: LazyUIImage,
            faceIdIcon: LazyUIImage)
        {
            self.logo = logo
            self.successImage = successImage
            self.failureImage = failureImage
            self.touchIdIcon = touchIdIcon
            self.faceIdIcon = faceIdIcon
        }
    }
    
    public struct Buttons {
        /// Style for all digits on PIN keyboard. This kind of button is typically instantiated as "custom".
        public var pinDigits: ButtonStyle
        
        /// Style for all auxiliary buttons (backspace, cancel, etc...) on PIN keyboard.
        /// This kind of button is typically instantiated as "custom".
        public var pinAuxiliary: ButtonStyle
        
        /// "OK" button used in scene with variable PIN length, or in alphanumeric password.
        /// This kind of button is typically instantiated as "custom".
        public var ok: ButtonStyle
        
        /// A "Close / Cancel" button used typically on alphanumeric password picker.
        /// This kind of button is typically instantiated as "system".
        public var close: ButtonStyle
        
        /// A "Close error" button, used after authentication operation fails
        /// This kind of button is typically instantiated as "custom".
        public var dismissError: ButtonStyle
        
        /// Style for button embededd in keyboard's accessory view. This button is typically
        /// used when a new alphanumeric password is going to be created ("Choose password complexity"),
        /// or as biometry button on alphanumeric password picker ("Use Touch ID / Use Face ID")
        /// This kind of button is typically instantiated as "system".
        public var keyboardAuxiliary: ButtonStyle
        
        /// Structure initializer
        public init(
            pinDigits: ButtonStyle,
            pinAuxiliary: ButtonStyle,
            ok: ButtonStyle,
            close: ButtonStyle,
            dismissError: ButtonStyle,
            keyboardAuxiliary: ButtonStyle)
        {
            self.pinDigits = pinDigits
            self.pinAuxiliary = pinAuxiliary
            self.ok = ok
            self.close = close
            self.dismissError = dismissError
            self.keyboardAuxiliary = keyboardAuxiliary
        }
    }
    
    // MARK: - Theme content
    
    public var common: Common
    public var images: Images
    public var buttons: Buttons
    
    /// Theme initializer
    public init(
        common: Common,
        images: Images,
        buttons: Buttons)
    {
        self.common = common
        self.images = images
        self.buttons = buttons
    }
    
    /// Function provides a fallback theme used internally, for theme initial values.
    public static func fallbackTheme() -> LimeAuthAuthenticationUITheme {
        return LimeAuthAuthenticationUITheme(
            common: Common(
                backgroundColor: .white,
                topPartBackgroundColor: .clear,
                backgroundImage: nil,
                promptTextColor: .black,
                highlightedTextColor: .purple,
                passwordTextColor: .black,
                wrongPasswordTextColor: .red,
                activityIndicator: .small(.blue),
                passwordTextField: .noStyle,
                passwordBorderWidth: 0,
                passwordBorderColor: nil,
                passwordBorderCornerRadius: 0,
                statusBarStyle: .default
            ),
            images: Images(
                logo: nil,
                successImage: .empty,
                failureImage: .empty,
                touchIdIcon: .empty,
                faceIdIcon: .empty
            ),
            buttons: Buttons(
                pinDigits: .noStyle,
                pinAuxiliary: .noStyle,
                ok: .noStyle,
                close: .noStyle,
                dismissError: .noStyle,
                keyboardAuxiliary: .noStyle
            )
        )
    }
}
