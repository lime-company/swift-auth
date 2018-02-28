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

public enum Activation {
    
    public enum Result {
        case success
        case failure
        case cancel
    }
    
    public class Data {
        
        public var activationCode: String?
        
        public var createActivationResult: PA2ActivationResult?
        
        public var password: String?
        
        public var useBiometry: Bool = false
        
        public var result: Result?
        
        public var failureReason: Error?
    }

    
    public struct UIData {

        public struct CommonStrings {
            public let okTitle: String
            public let cancelTitle: String
            public let closeTitle: String
            
            public static func fallbackStrings() -> CommonStrings {
                return CommonStrings(okTitle: "OK",
                                     cancelTitle: "Cancel",
                                     closeTitle: "Close")
            }
        }
        
        public let commonStrings: CommonStrings
        
        public let beginActivation: BeginActivation.UIData
        public let noCameraAccess: NoCameraAccess.UIData
        public let enterActivationCode: EnterActivationCode.UIData
        public let scanActivationCode: ScanActivationCode.UIData
        public let keysExchange: KeysExchange.UIData
        public let enableBiometry: EnableBiometry.UIData
        public let confirmActivation: ConfirmActivation.UIData
        
        public let errorActivation: ErrorActivation.UIData
        public let successActivation: SuccessActivation.UIData
    }
}
