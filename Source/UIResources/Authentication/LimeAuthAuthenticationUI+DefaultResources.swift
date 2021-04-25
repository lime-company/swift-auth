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
import LimeCore

public extension LimeAuthAuthenticationUI {
    
    /// Function returns a default authentication UI provider. You can optionally provide a theme, which will be applied to created UI components.
    /// Also you can optionally provide a bundle with a storyboard, compatible with `Authentication.storyboard`, which is normally provided by
    /// the library itself.
    ///
    /// - parameter theme: Optional theme applied to UI. If nil, then `.defaultLightTheme()` is used
    /// - parameter bundle: Optional bundle, containing a compatible `Authentication.storyboard`
    /// - returns: object providing authentication UI
    static func defaultResourcesProvider(theme: LimeAuthAuthenticationUITheme? = nil,
                                         localizationProvider: GenericLocalizationProvider? = nil,
                                         bundle: Bundle? = nil,
                                         recoveryClosure: @escaping @autoclosure ()->RecoveryUIProvider) -> AuthenticationUIProvider {
        let provider = DefaultAuthenticationResourcesProvider(bundle: bundle, localizationProvider: localizationProvider, recoveryClosure: recoveryClosure())
        provider.loadTheme(theme: theme ?? .defaultLightTheme())
        return provider
    }
}

public extension LimeAuthAuthenticationUITheme.Images {
    
    /// Function returns a default set of images bundled with the LimeAuth.framework. You can optionally provide your own bundle
    /// if that bundle contains the same set of images with the same naming scheme as is using the library. You can also optionally
    /// provide just an application's logo.
    ///
    /// Usage examples:
    /// * `.defaultImages(logo: .named("your-app-logo")`, will provide default images from library, but logo is provided by the application.
    /// * `.defaultImages(logo: .named("your-app-logo", bundle: Main.bundle)`, will load logo and all icons from `Main.bundle`.
    ///
    /// Note that `Icons.xcassets` has to be a part of the library's build, otherwise no image will be provided.
    ///
    /// - parameter logo: Optional lazy image containing your custom logo
    /// - parameter bundle: Optional bundle, from whom all icons will be loaded.
    /// - returns: New Images structure.
    static func defaultImages(logo: LazyUIImage? = nil, bundle: Bundle? = nil) -> LimeAuthAuthenticationUITheme.Images {
        let bundle = bundle ?? Bundle.limeAuthResourcesBundle
        return LimeAuthAuthenticationUITheme.Images(
            logo: logo,
            successImage: .named("ic-success", bundle: bundle),
            failureImage: .named("ic-error", bundle: bundle),
            touchIdIcon: .named("ic-touchid", bundle: bundle),
            faceIdIcon: .named("ic-faceid", bundle: bundle)
        )
    }
}


public extension LimeAuthAuthenticationUITheme {
    
    /// Function returns a default light theme for authentication UI. You can optionally provide a Images part
    /// of theme structure, if you have your own custom images.
    static func defaultLightTheme(images: Images? = nil) -> LimeAuthAuthenticationUITheme {
        
//        let bigButtonFont = UIFont.systemFont(ofSize: 18.0)
//        let smallButtonFont = UIFont.systemFont(ofSize: 16.0)
        
        return LimeAuthAuthenticationUITheme(
            common: Common(
                backgroundColor: .white,
                topPartBackgroundColor: .white,
                backgroundImage: nil,
                promptTextColor: .black,
                highlightedTextColor: .purple,
                passwordTextColor: .black,
                wrongPasswordTextColor: .red,
                activityIndicator: .large(.orange),
                passwordTextField: .noStyle,
                passwordBorderWidth: 2,
                passwordBorderColor: .lightGray,
                passwordBorderCornerRadius: 16,
                statusBarStyle: .default,
                emptyPinDotColor: .gray,
                filledPinDotColor: .black
            ),
            images: images ?? .defaultImages(),
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
    
    /// Function returns a default dark theme for authentication UI. You can optionally provide a Images part
    /// of theme structure, if you have your own custom images.
    static func defaultDarkTheme(images: Images? = nil) -> LimeAuthAuthenticationUITheme {
        
        let bigButtonFont = UIFont.systemFont(ofSize: 18.0)
        let smallButtonFont = UIFont.systemFont(ofSize: 16.0)
        
        return LimeAuthAuthenticationUITheme(
            common: Common(
                backgroundColor: .black,
                topPartBackgroundColor: .black,
                backgroundImage: nil,
                promptTextColor: .lightGray,
                highlightedTextColor: .lightGray,
                passwordTextColor: .orange,
                wrongPasswordTextColor: .red,
                activityIndicator: .large(.orange),
                passwordTextField: TextFieldStyle(
                    tintColor: .orange,
                    backgroundColor: .clear,
                    textColor: .orange,
                    textFont: .systemFont(ofSize: 17.0),
                    borderWidth: 2.0,
                    borderColor: .orange,
                    borderCornerRadius: 16.0,
                    keyboardAppearance: .dark,
                    options: .default
                ),
                passwordBorderWidth: 2,
                passwordBorderColor: .lightGray,
                passwordBorderCornerRadius: 16,
                statusBarStyle: .lightContent,
                emptyPinDotColor: .gray,
                filledPinDotColor: .white
            ),
            images: images ?? .defaultImages(),
            buttons: Buttons(
                pinDigits: ButtonStyle(
                    tintColor: nil,
                    backgroundColor: .highlighted(.gray),
                    titleColor: .colors(.gray, .black),
                    titleFont: UIFont(name: "HelveticaNeue-Light", size: 44.0),
                    title: nil,
                    image: nil,
                    borderWidth: 2.0,
                    borderColor: .same(.darkGray),
                    borderCornerRadius: 0.0,
                    options: [.isRounded]
                ),
                pinAuxiliary: ButtonStyle(
                    tintColor: nil,
                    backgroundColor: .highlighted(.gray),
                    titleColor: .colors(.gray, .black),
                    titleFont: .systemFont(ofSize: 33.0),
                    title: nil,
                    image: nil,
                    borderWidth: 0.0,
                    borderColor: .same(.darkGray),
                    borderCornerRadius: 0.0,
                    options: [.isRounded]
                ),
                ok: ButtonStyle(
                    tintColor: .orange,
                    backgroundColor: .clear,
                    titleColor: nil,
                    titleFont: .systemFont(ofSize: 21.0),
                    title: nil,
                    image: nil,
                    borderWidth: 2.0,
                    borderColor: nil,
                    borderCornerRadius: 4.0,
                    options: .default
                ),
                close: ButtonStyle(
                    tintColor: .orange,
                    backgroundColor: .clear,
                    titleColor: nil,
                    titleFont: smallButtonFont,
                    title: nil,
                    image: nil,
                    borderWidth: 0.0,
                    borderColor: nil,
                    borderCornerRadius: 4.0,
                    options: .default
                ),
                dismissError: ButtonStyle(
                    tintColor: nil,
                    backgroundColor: .clear,
                    titleColor: nil,
                    titleFont: bigButtonFont,
                    title: nil,
                    image: nil,
                    borderWidth: 0.0,
                    borderColor: nil,
                    borderCornerRadius: 4.0,
                    options: .default
                ),
                keyboardAuxiliary: ButtonStyle(
                    tintColor: .orange,
                    backgroundColor: .clear,
                    titleColor: nil,
                    titleFont: bigButtonFont,
                    title: nil,
                    image: nil,
                    borderWidth: 0.0,
                    borderColor: nil,
                    borderCornerRadius: 4.0,
                    options: .default
                )
            )
        )
    }

}

