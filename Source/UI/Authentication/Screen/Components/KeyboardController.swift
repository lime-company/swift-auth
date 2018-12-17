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
import PowerAuth2

protocol PinKeyboardDelegate: class {
    func pinKeyboard(_ sender: PinKeyboardController, didTapDigit digit: Int)
    func pinKeyboard(_ sender: PinKeyboardController, didTapSpecialKey key: PinKeyboardSpecialKey)
    func pinKeyboard(_ sender: PinKeyboardController, imageFor biometryIcon: PinKeyboardBiometryIcon) -> UIImage?
}

class PinKeyboardController: UIViewController {
    
    /// Factory method
    static func create() -> PinKeyboardController {
        let ctrl = PinKeyboardController(nibName: "Keyboard", bundle: Bundle(for: PinKeyboardController.self))
        ctrl.loadView()
        return ctrl
    }
    
    /// Delegate
    weak var delegate: PinKeyboardDelegate!
    
    // MARK: IB outlets
    
    /// Keyboard is expecting 10 buttons in this collection. Each button must have set
    /// tag with number from 0 to 9, representing value.
    @IBOutlet var numericButtonsCollection: [UIButton]!
    
    /// Outlet for cancelButton. If the referenced button is the same as `backspaceButton`, then
    /// keyboard will use the same button for both operations.
    @IBOutlet var cancelButton: UIButton?
    
    /// Outlet for backspaceButton. If the referenced button is the same as `cancelButton`, then
    /// keyboard will use the same button for both operations.
    @IBOutlet var backspaceButton: UIButton?
    
    /// Button dedicated for biometry action
    @IBOutlet var biometryButton: UIButton?
    
    /// Title text which will be used when the shared button behaves as cancel
    private var titleForSharedCancelButton = "✕"
    
    /// Title text which will be used when the shared button behaves as backspace
    private var titleForSharedBackspaceButton = "←"
    
    // MARK: Controlling keyboard
    
    /// Returns true when cancel and backspace shares the same button
    var isBackspaceSharedWithCancel: Bool {
        return cancelButton == backspaceButton
    }
    
    /// Disables or Enables all buttons in the keyboard
    var isKeyboardEnabled: Bool = false {
        didSet {
            enableAllButtons(isKeyboardEnabled)
        }
    }
    
    override func loadView() {
        super.loadView()
        viewDidLoad()
    }
    
    /// The `awakeFromNib` implementation setups buttons configuration. This means that this view should be instantiated
    /// only from the storyboards or nibs.
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()
    }
    
    /// Controls whether the special button is visible
    func setSpecialKeyVisible(_ specialKey: PinKeyboardSpecialKey, visible: Bool) {
        if specialKey == .biometry {
            // just hide or show biometry button
            setupBiometryButton()
            biometryButton?.isHidden = !visible
            //
        } else if isBackspaceSharedWithCancel {
            // cancel & backspace are shared
            let keyBefore = keyForSharedBackspaceAndCancel
            if specialKey == .cancel {
                isSharedCancelVisible = visible
            } else if specialKey == .backspace {
                isSharedBackspaceVisible = visible
            }
            let keyAfter = keyForSharedBackspaceAndCancel
            if keyBefore != keyAfter {
                updateSharedBackspaceAndCancel(currentKey: keyForSharedBackspaceAndCancel)
            }
            //
        } else {
            // cancel & backspace have separate buttons
            let button = specialKey == .cancel ? cancelButton : backspaceButton
            button?.isHidden = !visible
            //
        }
    }
    
    /// Returns true if required special key is visible
    func isSpecialKeyVisible(_ specialKey: PinKeyboardSpecialKey) -> Bool {
        if specialKey == .biometry {
            if let b = biometryButton {
                return !b.isHidden
            }
        } else if isBackspaceSharedWithCancel {
            // Returns true if requested key is key currently in use
            if backspaceButton != nil, let currentKey = keyForSharedBackspaceAndCancel {
                return currentKey == specialKey
            }
        } else {
            if let b = specialKey == .cancel ? cancelButton : backspaceButton {
                return !b.isHidden
            }
        }
        // Not visible, due to missing view in required outlet
        return false
    }
    
    
    // Updates views according to current setup. You can override this method is derived class
    // to implement diffrent presentation of shared Backspace & Cancel key.
    func updateSharedBackspaceAndCancel(currentKey: PinKeyboardSpecialKey?) {
        if let currentKey = currentKey {
            let nextTitle = currentKey == .cancel ? titleForSharedCancelButton : titleForSharedBackspaceButton
            backspaceButton?.setTitle(nextTitle, for: .normal)
            backspaceButton?.isHidden = false
        } else {
            backspaceButton?.setTitle("", for: .normal)
            backspaceButton?.isHidden = true
        }
    }
    
    // MARK: - Styling
    
    /// Applies ButtonStyle to numberic and auxiliary buttons.
    func applyButtonStyle(forDigits digits: ButtonStyle, forAuxiliary auxiliary: ButtonStyle) {
        self.numericButtonsCollection?.forEach { (button) in
            button.applyButtonStyle(digits)
        }
        // Apply to all other buttons
        biometryButton?.applyButtonStyle(auxiliary)
        backspaceButton?.applyButtonStyle(auxiliary)
        if !isBackspaceSharedWithCancel {
            cancelButton?.applyButtonStyle(auxiliary)
        }
    }
    
    // MARK: - Private variables
    
    /// Current behavior for shared cancel & backspace button
    private var isSharedCancelVisible: Bool = false
    private var isSharedBackspaceVisible: Bool = false
    private var keyForSharedBackspaceAndCancel: PinKeyboardSpecialKey? {
        if isSharedCancelVisible {
            return .cancel
        } else if isSharedBackspaceVisible {
            return .backspace
        }
        return nil
    }
    
    /// Permutations for button tags
    private var tagPermutations: [Int]!
    
    // MARK: - Private functions
    
    /// Setups buttons for later usage.
    /// Returns false if subviews configuration is invalid.
    @discardableResult private func setupButtons() -> Bool {
        if numericButtonsCollection.count != 10 {
            assert(false, "Number of buttons in collection must be equal to 10")
            return false
        }
        if makePermutations() == false {
            return false
        }
        for button in numericButtonsCollection {
            button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        }
        backspaceButton?.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        biometryButton?.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        if !isBackspaceSharedWithCancel {
            cancelButton?.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        }
        // make all special buttons as hidden
        biometryButton?.isHidden = true
        cancelButton?.isHidden = true
        backspaceButton?.isHidden = true
        return true
    }
    
    /// Setups icon for the biometry button
    private var biometryButtonConfigured = false
    
    private func setupBiometryButton() {
        if !biometryButtonConfigured {
            let biometryType = PA2Keychain.supportedBiometricAuthentication
            let image: UIImage?
            if biometryType != .none {
                image = delegate.pinKeyboard(self, imageFor: biometryType == .faceID ? .faceID : .touchID)
            } else {
                image = nil
            }
            biometryButton?.setImage(image, for: .normal)
            biometryButtonConfigured = true
        }
    }
    
    /// Setups random tags into the buttons
    private func makePermutations() -> Bool {
        var permutations = [Int](repeating: 0, count: 10)
        let getTag: ()->Int = {
            while true {
                let tag = Int(arc4random_uniform(2147483647))
                if !permutations.contains(tag) {
                    return tag
                }
            }
        }
        
        // Iterate over all numberic buttons
        for button in numericButtonsCollection {
            let oldTag = button.tag
            if oldTag < 0 || oldTag > 9 {
                assert(false, "Tag is out of bounds")
                return false
            }
            let newTag = getTag()
            permutations[oldTag] = newTag
            button.tag = newTag
        }
        // backspace
        let backspaceTag = getTag()
        backspaceButton?.tag = backspaceTag
        permutations.append(backspaceTag)
        // cancel
        if !isBackspaceSharedWithCancel {
            let cancelTag = getTag()
            cancelButton?.tag = cancelTag
            permutations.append(cancelTag)
        } else {
            permutations.append(backspaceTag)
        }
        // biometry
        let biometryTag = getTag()
        biometryButton?.tag = biometryTag
        permutations.append(biometryTag)
        
        self.tagPermutations = permutations
        return true
    }
    
    /// Translates view's tag into the digit or special key code.
    private func translateTagToKey(_ tag: Int) -> (digit: Int?, code: PinKeyboardSpecialKey?) {
        if let index = tagPermutations?.index(of: tag) {
            if index < 10 {
                return (index, nil)
            } else if index == PinKeyboardSpecialKey.biometry.rawValue {
                return (nil, .biometry)
            } else {
                let shared = isBackspaceSharedWithCancel
                if index == PinKeyboardSpecialKey.backspace.rawValue {
                    return (nil, shared ? keyForSharedBackspaceAndCancel : .backspace)
                } else if index == PinKeyboardSpecialKey.cancel.rawValue {
                    return (nil, shared ? keyForSharedBackspaceAndCancel : .cancel)
                }
            }
        }
        return (nil, nil)
    }
    
    /// Implements common action for all buttons used by this view.
    @objc private func buttonAction(_ sender: UIButton) {
        let key = translateTagToKey(sender.tag)
        if let digit = key.digit {
            delegate?.pinKeyboard(self, didTapDigit: digit)
        } else if let code = key.code {
            delegate?.pinKeyboard(self, didTapSpecialKey: code)
        }
    }
    
    /// Enables or disables all buttons used by this view
    private func enableAllButtons(_ enable: Bool) {
        for button in numericButtonsCollection {
            button.isEnabled = enable
        }
        cancelButton?.isEnabled = enable
        biometryButton?.isEnabled = enable
        if !isBackspaceSharedWithCancel {
            backspaceButton?.isEnabled = enable
        }
    }
}
