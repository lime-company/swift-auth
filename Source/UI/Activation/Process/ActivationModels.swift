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
import PowerAuth2

public enum Activation {
    
    public enum Result {
        case success
        case failure
        case cancel
    }
    
    public class Data {
        
        public var activationCode: String?
        
        public var puk: String? // needed for activation via recovery
        
        public var createActivationResult: PowerAuthActivationResult?
        
        public var recoveryFromFailedActivation = false
        
        public var password: String?
        
        public var useBiometry = false
        
        public var activationOTP: String? // when additional OTP is needed
        
        public var result: Result?
        
        public var failureReason: LimeAuthError?
        
        public var failureReasonString: String?
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
    }
}
