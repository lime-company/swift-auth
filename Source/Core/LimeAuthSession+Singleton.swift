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
import LimeCore
import PowerAuth2

// MARK: - LimeAuthSession singleton -

public extension LimeAuthSession {
    
    public static let shared: LimeAuthSession = LimeAuthSession(config: LimeConfig.shared.authSession)
    
}


// MARK: - LimeAuthSessionConfig as domain in LimeConfig -

public extension LimeConfig {
    
    public var authSession: LimeAuthSessionConfig {
        if let cfg: MutableLimeAuthSessionConfig = self.config(for: LimeConfig.domainForAuthSession) {
            return cfg;
        }
        return LimeConfig.fallbackAuthSessionConfig
    }

    public var registerAuthSession: MutableLimeAuthSessionConfig? {
        return self.register(MutableLimeAuthSessionConfig(), for: LimeConfig.domainForAuthSession)
    }
    
    /// Domain for config registration
    private static let domainForAuthSession = "lime.authSession"
    
    /// Fallback object returned when localization domain has not been properly registered.
    private static let fallbackAuthSessionConfig = MutableLimeAuthSessionConfig(powerAuth: PowerAuthConfiguration())
}
