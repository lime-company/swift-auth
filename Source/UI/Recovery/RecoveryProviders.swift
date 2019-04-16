//
// Copyright 2019 Wultra s.r.o.
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
import PowerAuth2

public protocol RecoveryUIProvider: class {
    
    func instantiateRecoveryController() -> RecoveryViewController
    
    var uiDataProvider: RecoveryUIDataProvider { get }
}

public protocol RecoveryUIDataProvider: class {
    
    /// UI elements branding/coloring
    var uiTheme: LimeAuthRecoveryUITheme { get }
    
    /// Strings that are used when the recovery info is displayed during activation
    var activationStrings: RecoveryCode.UIData.Strings { get }
    /// Strings that are used when the recovery info is displayd during activation that was started with activation codes
    var reactivationStrings: RecoveryCode.UIData.Strings { get }
    /// Strings that are used when the recovery info is displayed after the activation (when user request to see them again)
    var standaloneStrings: RecoveryCode.UIData.Strings { get }
    /// Strings that are used when user takes screenshot of the recovery code
    var screenshotAlertStrings: RecoveryCode.UIData.ScreenshotStrings { get }
}
