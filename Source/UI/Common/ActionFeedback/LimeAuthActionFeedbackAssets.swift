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

/// Type of haptic feedback
public enum LimeAuthHapticType {
    case impact(LimeAuthHapticImpactStrength)
    case notification(LimeAuthHapticNotificationType)
    case selection
}

/// Strength of haptic impact (vibration)
public enum LimeAuthHapticImpactStrength {
    case light
    case medium
    case heavy
}

/// Type of haptic notification
public enum LimeAuthHapticNotificationType {
    case success
    case warning
    case error
}

/// System sound defined in system
public enum LimeAuthSystemSound: Int {
    case tink = 1103
    case tock = 1104
    case tock2 = 1105
}

/// Predefined events for specific LimeAuth situations
public enum LimeAuthFeedbackScene {
    case digitKeyPressed
    case specialKeyPressed
    case operationSuccess
    case operationFail
}
