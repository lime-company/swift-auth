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

public enum ConfirmActivation {
    
    public struct UIData {
        
        public struct Strings {
            let sceneTitle: String
            let sceneDescription: String
            let waitingLabel: String
            let removeActivationButton: String
        }
        
        public let strings: Strings
        
        public static func fallbackData() -> UIData {
            return UIData(
                strings: Strings(
                    sceneTitle: "Complete the activation",
                    sceneDescription: "Please check whether the Confirmation number displayed matches the number on the ePortal screen. If so, confirm it in ePortal.",
                    waitingLabel: "Waiting for activation completion",
                    removeActivationButton: "Cancel operation"
                )
            )
        }
        
    }
}


