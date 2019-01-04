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
import AudioToolbox

// "Abstract" class for vibration
class VibrationEngine {
    
    // use static create() method instead
    fileprivate init() {
        
    }
    
    /// Will vibrate given type.
    /// Availability and type of vibration is based on the device and not all types are available on older devices
    func play(_ what: LimeAuthHapticType) {
        // to override
    }
    
    /// Puts engine to sleep
    func sleep() {
        // to override
    }
    
    /// Wakes up the engine to get imidiate responses when play is called
    func prepare() {
        // to override
    }
    
    /// Factory function
    static func create() -> VibrationEngine {
        
        if UIDevice.hasHapticEngine {
            return HapticEngine()
        }
        
        if UIDevice.hasTapticEngine {
            return TapticEngine()
        }
        
        return DefaultEngine()
    }
}

/// Default vibrations that are available in every iphone
fileprivate class DefaultEngine: VibrationEngine {
    
    public enum Vibration: UInt32 {
        /// Basic 1-second vibration
        case `default` = 4095
        /// Two short consecutive vibrations
        case alert = 1011
    }
    
    override func play(_ what: LimeAuthHapticType) {
        
        switch what {
        case .notification(let notificationType):
            switch notificationType {
            case .success: vibrate(.default)
            case .warning: vibrate(.alert)
            case .error: vibrate(.alert)
            }
        default:
            // dont do anything
            break
        }
    }
    
    private func vibrate(_ what: Vibration) {
        AudioServicesPlaySystemSound(what.rawValue)
    }
}

// Haptic engine version 1 (for 6S and 6S+)
fileprivate class TapticEngine: VibrationEngine {
    
    private enum TapticPattern: UInt32 {
        /// Weak boom
        case peek = 1519
        /// Strong boom
        case pop = 1520
        /// Three sequential weak booms
        case cancelled = 1521
        /// Weak boom then strong boom
        case tryAgain = 1102
        /// Three sequential strong booms
        case failed = 1107
    }
    
    override func play(_ what: LimeAuthHapticType) {
        
        switch what {
        case .impact(let strength):
            switch strength {
            case .light: vibrate(.peek)
            case .medium: vibrate(.peek)
            case .heavy: vibrate(.pop)
            }
        case .notification(let notificationType):
            switch notificationType {
            case .success: vibrate(.tryAgain)
            case .warning: vibrate(.failed)
            case .error: vibrate(.failed)
            }
        case .selection:
            vibrate(.peek)
        }
    }
    
    private func vibrate(_ what: TapticPattern) {
        AudioServicesPlaySystemSound(what.rawValue)
    }
}

// Haptic engine version 2 (for 7 and later)
fileprivate class HapticEngine: VibrationEngine {
    
    private var impactLight: UIImpactFeedbackGenerator?
    private var impactMedium: UIImpactFeedbackGenerator?
    private var impactHeavy: UIImpactFeedbackGenerator?
    private var notification: UINotificationFeedbackGenerator?
    private var selection: UISelectionFeedbackGenerator?
    private var generators: [UIFeedbackGenerator?] { return [impactLight, impactMedium, impactHeavy, notification, selection] }
    
    override func play(_ what: LimeAuthHapticType) {
        
        if impactLight == nil {
            wakeUp()
        }
        
        switch what {
        case .impact(let strength):
            switch strength {
            case .light: impactLight?.impactOccurred()
            case .medium: impactMedium?.impactOccurred()
            case .heavy: impactHeavy?.impactOccurred()
            }
        case .notification(let notificationType):
            switch notificationType {
            case .success: notification?.notificationOccurred(.success)
            case .warning: notification?.notificationOccurred(.warning)
            case .error: notification?.notificationOccurred(.error)
            }
        case .selection:
            selection?.selectionChanged()
        }
    }
    
    override func sleep() {
        impactLight = nil
        impactMedium = nil
        impactHeavy = nil
        notification = nil
        selection = nil
    }
    
    override func prepare() {
        if impactLight == nil {
            wakeUp()
        }
        generators.forEach { $0?.prepare() }
    }
    
    private func wakeUp() {
        impactLight = UIImpactFeedbackGenerator(style: .light)
        impactMedium = UIImpactFeedbackGenerator(style: .medium)
        impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
        notification = UINotificationFeedbackGenerator()
        selection = UISelectionFeedbackGenerator()
    }
}
