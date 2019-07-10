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

public enum ConfirmActivation {
    
    public struct UIData {
        
        public struct Strings {
            public let sceneTitle: String
            public let sceneDescription: String
            public let waitingLabel: String
            public let removeActivationButton: String
            
            public init(sceneTitle: String, sceneDescription: String, waitingLabel: String, removeActivationButton: String) {
                self.sceneTitle = sceneTitle
                self.sceneDescription = sceneDescription
                self.waitingLabel = waitingLabel
                self.removeActivationButton = removeActivationButton
            }
        }
        
        public struct Errors {
            public let activation: String              // General error
            public let activationRemoved: String       // If activation has been removed
            public let activationBlocked: String       // If activation has been blocked
            public let passwordSetupFailure: String    // On unsuccessfull activation commit (typically fails on encryption error)
            public let recoveryFailure: String         // If it's not possible to recovery from broken activation
            
            public init(activation: String, activationRemoved: String, activationBlocked: String, passwordSetupFailure: String, recoveryFailure: String) {
                self.activation = activation
                self.activationRemoved = activationRemoved
                self.activationBlocked = activationBlocked
                self.passwordSetupFailure = passwordSetupFailure
                self.recoveryFailure = recoveryFailure
            }
        }
        
        public struct Other {
            /// How many tries before "Cancel Activation" button is presented.
            /// Polling is happening every 2 seconds.
            public let statusCheckCountBeforeCancelButton: Int
            
            public init(statusCheckCountBeforeCancelButton: Int) {
                self.statusCheckCountBeforeCancelButton = statusCheckCountBeforeCancelButton
            }
        }
        
        public let strings: Strings
        public let errors: Errors
        public let other: Other
        
        public init(strings: Strings, errors: Errors, other: Other) {
            self.strings = strings
            self.errors = errors
            self.other = other
        }
    }
}


