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
    
    public static func defaultResourcesProvider(bundle: Bundle? = nil, theme: LimeAuthActivationUI.Theme? = nil) -> ActivationUIProvider {
        let provider = DefaultActivationResourcesProvider(bundle: bundle)
        provider.loadTheme(theme: theme ?? LimeAuthActivationUI.defaultLightTheme())
        return provider
    }
    
    
    public static func defaultLightTheme(illustrations: LimeAuthActivationUI.Theme.Illustrations? = nil) -> LimeAuthActivationUI.Theme {
        
        let illustrations = illustrations ??
            LimeAuthActivationUI.Theme.Illustrations(
                beginScene: .empty,
                noCameraScene: .empty,
                enableBiometryScene: .empty,
                confirmScene: .empty,
                errorScene: .empty)
        
        let bigButtonFont = UIFont.systemFont(ofSize: 18.0)
        let smallButtonFont = UIFont.systemFont(ofSize: 16.0)
        
        return LimeAuthActivationUI.Theme(
            common: LimeAuthActivationUI.Theme.Common(
                backgroundColor: .white,
                backgroundImage: nil,
                titleColor: .orange,
                textColor: .black,
                highlightedTextColor: .orange,
                activityIndicator: .small(.orange),
                keyboardAppearance: .default
            ),
            illustrations: illustrations,
            images: LimeAuthActivationUI.Theme.Images(
                scannerCrosshair: .empty
            ),
            buttons: LimeAuthActivationUI.Theme.Buttons(
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
            scannerScene: LimeAuthActivationUI.Theme.ScannerScene(
                statusBarStyle: .default,
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
            )
        )
    }
    
    public static func defaultDarkTheme(illustrations: LimeAuthActivationUI.Theme.Illustrations? = nil) -> LimeAuthActivationUI.Theme {
        
        let illustrations = illustrations ??
            LimeAuthActivationUI.Theme.Illustrations(
                beginScene: .empty,
                noCameraScene: .empty,
                enableBiometryScene: .empty,
                confirmScene: .empty,
                errorScene: .empty)
        
        let bigButtonFont = UIFont.systemFont(ofSize: 18.0)
        let smallButtonFont = UIFont.systemFont(ofSize: 16.0)
        
        return LimeAuthActivationUI.Theme(
            common: LimeAuthActivationUI.Theme.Common(
                backgroundColor: .black,
                backgroundImage: nil,
                titleColor: .orange,
                textColor: .white,
                highlightedTextColor: .orange,
                activityIndicator: .small(.orange),
                keyboardAppearance: .dark
            ),
            illustrations: illustrations,
            images: LimeAuthActivationUI.Theme.Images(
                scannerCrosshair: .empty
            ),
            buttons: LimeAuthActivationUI.Theme.Buttons(
                primary: ButtonStyle(
                    tintColor: nil,
                    backgrdoundColor: .same(.orange),
                    titleColor: .same(.white),
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
                    titleColor: .same(.orange),
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
            scannerScene: LimeAuthActivationUI.Theme.ScannerScene(
                statusBarStyle: .default,
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
            )
        )
    }
}

