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

public enum NewCredentials {
    
    public struct UIData {
        
        public struct Strings {
            
            public let enterNewPin: String
            public let retypePin: String
            public let pinNoMatch: String
            
            public let enterNewPassword: String
            public let retypePassword: String
            public let passwordNoMatch: String
            
            public let changeComplexityTitle: String
            public let changeComplexityButton: String
        }
        
        public let strings: Strings
    }
}
