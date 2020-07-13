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
import LimeCore

public extension LimeAuthActivationUI {
    
    static func defaultResourcesProvider(activationTheme: LimeAuthActivationUITheme? = nil,
                                         authenticationTheme: LimeAuthAuthenticationUITheme? = nil,
                                         localizationProvider: GenericLocalizationProvider? = nil,
                                         bundle: Bundle? = nil,
                                         recoveryClosure: @escaping @autoclosure ()->RecoveryUIProvider) -> ActivationUIProvider {
        let activationUIProvider = DefaultActivationResourcesProvider(
            bundle: bundle,
            localizationProvider: localizationProvider,
            authenticationUIProviderClosure: { () -> AuthenticationUIProvider in
                let authenticationUIProvider = DefaultAuthenticationResourcesProvider(bundle: bundle, localizationProvider: localizationProvider, recoveryClosure: recoveryClosure())
                authenticationUIProvider.loadTheme(theme: authenticationTheme ?? .defaultLightTheme())
                return authenticationUIProvider
            })
        activationUIProvider.loadTheme(theme: activationTheme ?? .defaultLightTheme())
        return activationUIProvider
    }
}

public extension LimeAuthActivationUITheme.Illustrations {
    
    static func defaultIllustrations(bundle: Bundle? = nil) -> LimeAuthActivationUITheme.Illustrations {
        let bundle = bundle ?? Bundle.limeAuthResourcesBundle
        return LimeAuthActivationUITheme.Illustrations(
            beginScene: .named("il-begin-scene", bundle: bundle),
            noCameraScene: .named("il-no-camera-scene", bundle: bundle),
            enableBiometryScene: .named("il-enable-biometry-scene", bundle: bundle),
            confirmScene: .named("il-confirm-scene", bundle: bundle),
            errorScene: .named("il-error-scene", bundle: bundle),
            beginRecoveryScene: .named("il-begin-recovery-scene", bundle: bundle)
        )
    }
    
}

public extension LimeAuthActivationUITheme.Images {
    
    static func defaultImages(bundle: Bundle? = nil) -> LimeAuthActivationUITheme.Images {
        let bundle = bundle ?? Bundle.limeAuthResourcesBundle
        return LimeAuthActivationUITheme.Images(
            scannerCrosshair: .named("scanner-crosshair", bundle: bundle)
        )
    }
    
}

public extension LimeAuthActivationUITheme {
    
    // default otp text field type
    private static var otpContentType: UITextContentType? {
        if #available(iOS 12.0, *) {
            return .oneTimeCode
        }
        return nil
    }
    
    static func defaultLightTheme(illustrations: Illustrations? = nil, images: Images? = nil) -> LimeAuthActivationUITheme {

        let bigButtonFont = UIFont.systemFont(ofSize: 18.0)
        let smallButtonFont = UIFont.systemFont(ofSize: 16.0)
        
        return LimeAuthActivationUITheme(
            common: Common(
                backgroundColor: .white,
                backgroundImage: nil,
                titleColor: .orange,
                titleFont: nil,
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
                    backgroundColor: .clear,
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
                    backgroundColor: .clear,
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
                    backgroundColor: .clear,
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
                    backgroundColor: .clear,
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
                    backgroundColor: .colors(.orange, .black),
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
                    backgroundColor: .clear,
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
            ),
            authOTP: ValidateOTPScene(
                otpCode: TextFieldStyle(
                    tintColor: nil,
                    backgroundColor: .white,
                    textColor: .black,
                    textFont: UIFont(name: "CourierNewPSMT", size: 18.0),
                    borderWidth: 1.0,
                    borderColor: .black,
                    borderCornerRadius: 8.0,
                    keyboardAppearance: .default,
                    options: [],
                    alignment: .center,
                    contentType: otpContentType
                )
            )
        )
    }
    
    static func defaultDarkTheme(illustrations: Illustrations? = nil, images: Images? = nil) -> LimeAuthActivationUITheme {
        
        let bigButtonFont = UIFont.systemFont(ofSize: 18.0)
        let smallButtonFont = UIFont.systemFont(ofSize: 16.0)
        
        return LimeAuthActivationUITheme(
            common: Common(
                backgroundColor: .black,
                backgroundImage: nil,
                titleColor: .rgb(0xFF9300),
                titleFont: nil,
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
                    backgroundColor: .colors(.rgb(0xFF9300), .argb(0xccFF9300), .rgb(0x5E5E5E)),
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
                    backgroundColor: .clear,
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
                    backgroundColor: .clear,
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
                    backgroundColor: .clear,
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
                    backgroundColor: .colors(.orange, .black),
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
                    backgroundColor: .clear,
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
            ),
            authOTP: ValidateOTPScene(
                otpCode: TextFieldStyle(
                    tintColor: nil,
                    backgroundColor: .black,
                    textColor: .white,
                    textFont: UIFont(name: "CourierNewPSMT", size: 18.0),
                    borderWidth: 1.0,
                    borderColor: .white,
                    borderCornerRadius: 8.0,
                    keyboardAppearance: .dark,
                    options: [],
                    alignment: .center,
                    contentType: otpContentType
                )
            )
        )
    }
}

