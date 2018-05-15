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

public extension LimeAuthActivationUI {
    
    public static func defaultResourcesProvider(activationTheme: LimeAuthActivationUITheme? = nil, authenticationTheme: LimeAuthAuthenticationUITheme? = nil, bundle: Bundle? = nil) -> ActivationUIProvider {
        let activationUIProvider = DefaultActivationResourcesProvider(bundle: bundle) { () -> AuthenticationUIProvider in
            let authenticationUIProvider = DefaultAuthenticationResourcesProvider(bundle: bundle)
            authenticationUIProvider.loadTheme(theme: authenticationTheme ?? .defaultLightTheme())
            return authenticationUIProvider
        }
        activationUIProvider.loadTheme(theme: activationTheme ?? .defaultLightTheme())
        return activationUIProvider
    }
}

public extension LimeAuthActivationUITheme.Illustrations {
    
    public static func defaultIllustrations(bundle: Bundle? = nil) -> LimeAuthActivationUITheme.Illustrations {
        let bundle = bundle ?? Bundle.limeAuthResourcesBundle
        return LimeAuthActivationUITheme.Illustrations(
            beginScene: .named("il-begin-scene", bundle: bundle),
            noCameraScene: .named("il-no-camera-scene", bundle: bundle),
            enableBiometryScene: .named("il-enable-biometry-scene", bundle: bundle),
            confirmScene: .named("il-confirm-scene", bundle: bundle),
            errorScene: .named("il-error-scene", bundle: bundle)
        )
    }
    
}

public extension LimeAuthActivationUITheme.Images {
    
    public static func defaultImages(bundle: Bundle? = nil) -> LimeAuthActivationUITheme.Images {
        let bundle = bundle ?? Bundle.limeAuthResourcesBundle
        return LimeAuthActivationUITheme.Images(
            scannerCrosshair: .named("scanner-crosshair", bundle: bundle)
        )
    }
    
}

public extension LimeAuthActivationUITheme {
    
    public static func defaultLightTheme(illustrations: Illustrations? = nil, images: Images? = nil) -> LimeAuthActivationUITheme {

        let bigButtonFont = UIFont.systemFont(ofSize: 18.0)
        let smallButtonFont = UIFont.systemFont(ofSize: 16.0)
        
        return LimeAuthActivationUITheme(
            common: Common(
                backgroundColor: .white,
                backgroundImage: nil,
                titleColor: .orange,
                textColor: .black,
                highlightedTextColor: .orange,
                activityIndicator: .small(.orange),
                keyboardAppearance: .default,
                statusBarStyle: .default
            ),
            illustrations: illustrations ?? .defaultIllustrations(),
            images: images ?? .defaultImages(),
            buttons: Buttons(
                primary: ButtonStyle(
                    tintColor: nil,
                    backgrdoundColor: .clear,
                    titleColor: .same(.orange),
                    titleFont: bigButtonFont,
                    title: nil,
                    image: nil,
                    borderWidth: 2.0,
                    borderColor: .same(.orange),
                    borderCornerRadius: 4.0,
                    options: .default
                ),
                secondary: ButtonStyle(
                    tintColor: nil,
                    backgrdoundColor: .clear,
                    titleColor: .normal(.orange),
                    titleFont: bigButtonFont,
                    title: nil,
                    image: nil,
                    borderWidth: 0.0,
                    borderColor: nil,
                    borderCornerRadius: 4.0,
                    options: .default
                ),
                destructive: ButtonStyle(
                    tintColor: nil,
                    backgrdoundColor: .clear,
                    titleColor: .normal(.red),
                    titleFont: bigButtonFont,
                    title: nil,
                    image: nil,
                    borderWidth: 2,
                    borderColor: .same(.red),
                    borderCornerRadius: 4.0,
                    options: .default
                ),
                cancel: ButtonStyle(
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
                )
            ),
            scannerScene: ScannerScene(
                statusBarStyle: .lightContent,
                titleColor: .white,
                closeButton: ButtonStyle(
                    tintColor: nil,
                    backgrdoundColor: .colors(.orange, .black),
                    titleColor: .colors(.white, .darkGray),
                    titleFont: .systemFont(ofSize: 32.0),
                    title: "✕",
                    image: nil,
                    borderWidth: 0.0,
                    borderColor: nil,
                    borderCornerRadius: 0.0,
                    options: [.isRounded]
                ),
                fallbackButton: ButtonStyle(
                    tintColor: .white,
                    backgrdoundColor: .clear,
                    titleColor: nil,
                    titleFont: .systemFont(ofSize: 14),
                    title: nil,
                    image: nil,
                    borderWidth: 1.0,
                    borderColor: nil,
                    borderCornerRadius: 4.0,
                    options: .default
                )
            ),
            enterCodeScene: EnterCodeScene(
                activationCode: TextFieldStyle(
                    tintColor: nil,
                    backgroundColor: .white,
                    textColor: .black,
                    textFont: UIFont(name: "CourierNewPSMT", size: 18.0),
                    borderWidth: 1.0,
                    borderColor: .black,
                    borderCornerRadius: 8.0,
                    keyboardAppearance: .default,
                    options: []
                )
            ),
            navigationBar: NavigationBar(
                backgroundColor: .white,
                titleColor: .orange,
                tintColor: .orange,
                buttonColor: .orange
            )
        )
    }
    
    public static func defaultDarkTheme(illustrations: Illustrations? = nil, images: Images? = nil) -> LimeAuthActivationUITheme {
        
        let bigButtonFont = UIFont.systemFont(ofSize: 18.0)
        let smallButtonFont = UIFont.systemFont(ofSize: 16.0)
        
        return LimeAuthActivationUITheme(
            common: Common(
                backgroundColor: .black,
                backgroundImage: nil,
                titleColor: .rgb(0xFF9300),
                textColor: .white,
                highlightedTextColor: .rgb(0xFF9300),
                activityIndicator: .small(.orange),
                keyboardAppearance: .dark,
                statusBarStyle: .lightContent
            ),
            illustrations: illustrations ?? .defaultIllustrations(),
            images: images ?? .defaultImages(),
            buttons: Buttons(
                primary: ButtonStyle(
                    tintColor: nil,
                    backgrdoundColor: .colors(.rgb(0xFF9300), .argb(0xccFF9300), .rgb(0x5E5E5E)),
                    titleColor: .colors(.white, .argb(0xEEFFFFFF), .rgb(0xD6D6D6)),
                    titleFont: bigButtonFont,
                    title: nil,
                    image: nil,
                    borderWidth: 0.0,
                    borderColor: nil,
                    borderCornerRadius: 4.0,
                    options: .default
                ),
                secondary: ButtonStyle(
                    tintColor: nil,
                    backgrdoundColor: .clear,
                    titleColor: .colors(.rgb(0xFF9300), .argb(0xccFF9300), .rgb(0x5E5E5E)),
                    titleFont: bigButtonFont,
                    title: nil,
                    image: nil,
                    borderWidth: 0.0,
                    borderColor: nil,
                    borderCornerRadius: 4.0,
                    options: .default
                ),
                destructive: ButtonStyle(
                    tintColor: nil,
                    backgrdoundColor: .clear,
                    titleColor: .colors(.rgb(0xFF0000), .argb(0xccFF0000)),
                    titleFont: bigButtonFont,
                    title: nil,
                    image: nil,
                    borderWidth: 0.0,
                    borderColor: nil,
                    borderCornerRadius: 4.0,
                    options: .default
                ),
                cancel: ButtonStyle(
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
                )
            ),
            scannerScene: ScannerScene(
                statusBarStyle: .lightContent,
                titleColor: .white,
                closeButton: ButtonStyle(
                    tintColor: nil,
                    backgrdoundColor: .colors(.orange, .black),
                    titleColor: .colors(.white, .darkGray),
                    titleFont: .systemFont(ofSize: 32.0),
                    title: "✕",
                    image: nil,
                    borderWidth: 0.0,
                    borderColor: nil,
                    borderCornerRadius: 0.0,
                    options: [.isRounded]
                ),
                fallbackButton: ButtonStyle(
                    tintColor: .white,
                    backgrdoundColor: .clear,
                    titleColor: nil,
                    titleFont: .systemFont(ofSize: 14),
                    title: nil,
                    image: nil,
                    borderWidth: 1.0,
                    borderColor: nil,
                    borderCornerRadius: 4.0,
                    options: .default
                )
            ),
            enterCodeScene: EnterCodeScene(
                activationCode: TextFieldStyle(
                    tintColor: nil,
                    backgroundColor: .black,
                    textColor: .white,
                    textFont: UIFont(name: "CourierNewPSMT", size: 18.0),
                    borderWidth: 1.0,
                    borderColor: .white,
                    borderCornerRadius: 8.0,
                    keyboardAppearance: .dark,
                    options: []
                )
            ),
            navigationBar: NavigationBar(
                backgroundColor: .black,
                titleColor: .orange,
                tintColor: .orange,
                buttonColor: .orange
            )
        )
    }
}

