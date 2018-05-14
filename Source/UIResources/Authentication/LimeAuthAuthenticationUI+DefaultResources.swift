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

public extension LimeAuthAuthenticationUI {
    
    public static func defaultResourcesProvider(bundle: Bundle? = nil, theme: LimeAuthAuthenticationUITheme? = nil) -> AuthenticationUIProvider {
        let provider = DefaultAuthenticationResourcesProvider(bundle: bundle)
        provider.loadTheme(theme: theme ?? .defaultLightTheme())
        return provider
    }
}

public extension LimeAuthAuthenticationUITheme.Images {
    
    public static func defaultImages(logo: LazyUIImage? = nil, bundle: Bundle? = nil) -> LimeAuthAuthenticationUITheme.Images {
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
    
    public static func defaultLightTheme(images: Images? = nil) -> LimeAuthAuthenticationUITheme {
        
//        let bigButtonFont = UIFont.systemFont(ofSize: 18.0)
//        let smallButtonFont = UIFont.systemFont(ofSize: 16.0)
        
        return LimeAuthAuthenticationUITheme(
            common: Common(
                backgroundColor: .white,
                backgroundImage: nil,
				promptTextColor: .black,
				highlightedTextColor: .purple,
				passwordTextColor: .black,
				wrongPasswordTextColor: .red,
                activityIndicator: .large(.orange),
                passwordTextField: .noStyle
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
    
    public static func defaultDarkTheme(images: Images? = nil) -> LimeAuthAuthenticationUITheme {
        
       	let bigButtonFont = UIFont.systemFont(ofSize: 18.0)
       	let smallButtonFont = UIFont.systemFont(ofSize: 16.0)
		
        return LimeAuthAuthenticationUITheme(
            common: Common(
                backgroundColor: .black,
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
                )
            ),
            images: images ?? .defaultImages(),
            buttons: Buttons(
                pinDigits: ButtonStyle(
					tintColor: nil,
					backgrdoundColor: .highlighted(.gray),
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
					backgrdoundColor: .highlighted(.gray),
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
                    backgrdoundColor: .clear,
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
                    backgrdoundColor: .clear,
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
                    backgrdoundColor: .clear,
                    titleColor: .same(.orange),
                    titleFont: bigButtonFont,
                    title: nil,
                    image: nil,
                    borderWidth: 0.0,
                    borderColor: nil,
                    borderCornerRadius: 4.0,
                    options: .default
                ),
                keyboardAuxiliary: ButtonStyle(
                    tintColor: nil,
                    backgrdoundColor: .clear,
                    titleColor: .same(.orange),
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

