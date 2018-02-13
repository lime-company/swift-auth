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
import PowerAuth2

public class LimeAuthSession {
    
    public private(set) var powerAuth: PowerAuthSDK
        
    public init() {
        self.powerAuth = PowerAuthSDK()
    }
    
}


// MARK: - Activation state checks -

public extension LimeAuthSession {
    
    public var canStartActivation: Bool {
        return powerAuth.canStartActivation()
    }
    
    public var hasPendingActivation: Bool {
        return powerAuth.hasPendingActivation()
    }
    
    public var hasValidActivation: Bool {
        return powerAuth.hasValidActivation()
    }
}
