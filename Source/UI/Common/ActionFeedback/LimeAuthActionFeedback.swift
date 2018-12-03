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
import AudioToolbox
import AVFoundation

/// Class that plays haptic and audio feedback for easier use.
/// For simplicity and configuration of default LimeAuth UI components use `shared` singleton.
public class LimeAuthActionFeedback: NSObject {
    
    /// When false, haptic(..) calls will be ignored
    public var hapticEnabled = true
    /// When false, audio(..) calls will be ignored
    public var audioEnabled = true
    
    /// Success sound in predefined success scene. Default value available only when LimeAuth/UIResources_Sounds pod is used.
    public var successSound: URL? = Bundle(for: LimeAuthActionFeedback.self).url(forResource: "success", withExtension: "m4a")
    /// Fail sound in predefined success scene. Default value available only when LimeAuth/UIResources_Sounds pod is used.
    public var failSound: URL? = Bundle(for: LimeAuthActionFeedback.self).url(forResource: "failed", withExtension: "m4a")
    
    // generators
    private var impactLight: UIImpactFeedbackGenerator?
    private var impactMedium: UIImpactFeedbackGenerator?
    private var impactHeavy: UIImpactFeedbackGenerator?
    private var notification: UINotificationFeedbackGenerator?
    private var selection: UISelectionFeedbackGenerator?
    private var generators: [UIFeedbackGenerator?] { return [impactLight, impactMedium, impactHeavy, notification, selection] }
    
    // player that will play custom sounds
    private lazy var player = AVQueuePlayer()
    
    public override init () {
        super.init()
    }
    
    // MARK: public API
    
    /// Clears generator objects. This will put haptic engine to sleep (on HW level).
    public func sleep() {
        impactLight = nil
        impactMedium = nil
        impactHeavy = nil
        notification = nil
        selection = nil
    }
    
    /// Prepares haptic engine for use (to remove potentional delay when haptic() is called.)
    public func prepare() {
        
        if hapticEnabled {
            if impactLight == nil {
                wakeUp()
            }
            generators.forEach { $0?.prepare() }
        }
        
        if audioEnabled {
            do {
                // This will set audio to play on background without interupting any music or video currently playing
                try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: .mixWithOthers)
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
            }
        }
    }
    
    /// Vibrates the phone with given type of haptic feedback.
    ///
    /// - Parameter type: type of haptic feedback
    ///
    /// Note that this won't have any effect when `hapticEnabled` is false.
    public func haptic(_ type: LimeAuthHapticType) {
        
        guard hapticEnabled else {
            return
        }
        
        if impactLight == nil {
            wakeUp()
        }
        
        switch type {
        case .impact(let strength):
            switch strength {
            case .light: impactLight?.impactOccurred()
            case .medium: impactMedium?.impactOccurred()
            case  .heavy: impactHeavy?.impactOccurred()
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
    
    /// Plays system audio
    ///
    /// - Parameter sound: System sound file reference
    ///
    /// Note that this won't have any effect when `audioEnabled` is false.
    /// Also volume level is controlled by the system (user).
    public func audio(_ sound: LimeAuthSystemSound) {
        guard audioEnabled else {
            D.print("Audio disabled, sound won't be played.")
            return
        }
        
        AudioServicesPlaySystemSound(SystemSoundID(sound.rawValue))
    }
    
    /// Plays custom audio
    ///
    /// - Parameters:
    ///   - sound: Path to custom audio
    ///   - volume: Volume that the sound will be played on. 0.5 by default. Range is <0,1>. Note that this is
    ///     relative volume to system volume.
    public func audio(_ sound: URL?, volume: Float = 0.5) {
        
        guard audioEnabled else {
            D.print("Audio disabled, sound won't be played.")
            return
        }
        
        guard let url = sound, FileManager.default.fileExists(atPath: url.path) else {
            D.warning("Audio file is not set or doesn't exist, sound won't be played.")
            return
        }
        
        player.removeAllItems()
        player.insert(AVPlayerItem(url: url), after: nil)
        player.volume = volume
        player.play()
    }
    
    /// Plays predefined scene with audio and haptic feedback. This could be affected by
    /// `hapticEnabled` and `audioEnabled` properties
    ///
    /// - Parameter scene: Type of scene to be played
    public func scene(_ scene: LimeAuthFeedbackScene) {
        
        switch scene {
        case .digitKeyPressed:
            audio(.tock)
            haptic(.impact(.light))
        case .specialKeyPressed:
            audio(.tock2)
            haptic(.impact(.light))
        case .operationSuccess:
            audio(successSound, volume: 0.25)
            haptic(.notification(.success))
        case .operationFail:
            audio(failSound, volume: 0.25)
            haptic(.notification(.error))
        }
    }
    
    // MARK: private helper methods
    
    /// Prepares haptic generators
    private func wakeUp() {
        impactLight = UIImpactFeedbackGenerator(style: .light)
        impactMedium = UIImpactFeedbackGenerator(style: .medium)
        impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
        notification = UINotificationFeedbackGenerator()
        selection = UISelectionFeedbackGenerator()
    }
}
