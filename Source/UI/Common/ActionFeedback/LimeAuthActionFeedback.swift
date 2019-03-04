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
public class LimeAuthActionFeedback: NSObject {
    
    /// When false, haptic(..) calls will be ignored
    public var hapticEnabled = true
    /// When false, audio(..) calls will be ignored
    public var audioEnabled = true
    
    /// When false (default value), no vibrations will be played on devices without taptic or haptic engine (phones like 6 or SE).
    public var allowFallbackVibrations = false {
        didSet {
            vibrationEngine = VibrationEngine.create(allowNontapticPhones: allowFallbackVibrations)
        }
    }
    
    /// Success sound in predefined success scene. Default value available only when LimeAuth/UIResources_Sounds pod is used.
    public var successSound: URL? = Bundle(for: LimeAuthActionFeedback.self).url(forResource: "success", withExtension: "m4a")
    /// Fail sound in predefined success scene. Default value available only when LimeAuth/UIResources_Sounds pod is used.
    public var failSound: URL? = Bundle(for: LimeAuthActionFeedback.self).url(forResource: "failed", withExtension: "m4a")
    
    private var vibrationEngine: VibrationEngine
    
    private var ongoingSound: LimeAuthSystemSound?
    
    // player that will play custom sounds
    private lazy var player = AVQueuePlayer()
    
    public override init() {
        vibrationEngine = VibrationEngine.create(allowNontapticPhones: allowFallbackVibrations)
        super.init()
    }
    
    // MARK: public API
    
    /// Clears generator objects. This will put haptic engine to sleep (on HW level).
    public func sleep() {
        vibrationEngine.sleep()
    }
    
    /// Prepares haptic engine for use (to remove potentional delay when haptic() is called.)
    public func prepare() {
        
        if hapticEnabled {
            vibrationEngine.prepare()
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
    ///
    /// Also, in some cases, the feedback might not be played. For example older device doesn't
    /// support it or the system decides to not to play it (low battery).
    public func haptic(_ type: LimeAuthHapticType) {
        
        guard hapticEnabled else {
            D.print("Haptic disabled, vibration won't be played")
            return
        }
        
        vibrationEngine.play(type)
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
        
        if let ongoingSound = ongoingSound {
            AudioServicesDisposeSystemSoundID(SystemSoundID(ongoingSound.rawValue))
            D.warning("sound \(ongoingSound.rawValue) canceled")
        }
        ongoingSound = sound
        AudioServicesPlaySystemSoundWithCompletion(SystemSoundID(sound.rawValue)) { [weak self] in
            self?.ongoingSound = nil
        }
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
}
