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

import UIKit
import PowerAuth2

@objc public protocol ActivationCodeDelegate: class {
    func codeChanged(code: String)
}

public class ActivationCodeView: UIView, UITextFieldDelegate {
    
    private weak var tf1: UITextField!
    private weak var tf2: UITextField!
    private weak var tf3: UITextField!
    private weak var tf4: UITextField!
    private var fields: [UITextField] { return [tf1, tf2, tf3, tf4] }
    
    @IBOutlet weak var delegate: ActivationCodeDelegate?
    @IBOutlet weak var afterFilledResponder: UIResponder?
    
    private let segmentLength = 5
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
    }
    
    // MARK: - public API
    
    public func prepareComponent(uiDataProvider: ActivationUIDataProvider) {
        createTextFields()
        fields.forEach { $0.applyTextFieldStyle(uiDataProvider.uiTheme.enterCodeScene.activationCode)}
    }
    
    public func buildCode() -> String {
        return fields.map { $0.text ?? "" }.joined(separator: "-")
    }
    
    public var isCodeFilled: Bool {
        return fields.allSatisfy { $0.text?.count == segmentLength }
    }
    
    // MARK: - Private helpers
    
    private var isEmptyCode: Bool {
        return fields.allSatisfy { $0.text?.isEmpty != false }
    }
    
    private func createTextFields() {
        
        guard tf1 == nil else {
            return
        }
        
        let sv = UIStackView(frame: .zero)
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .horizontal
        sv.alignment = .fill
        sv.distribution = .fillEqually
        sv.spacing = 4
        sv.backgroundColor = .clear
        
        tf1 = createTF(sv)
        tf2 = createTF(sv)
        tf3 = createTF(sv)
        tf4 = createTF(sv)
        
        addSubview(sv)
        addConstraint(sv.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1))
        addConstraint(sv.heightAnchor.constraint(equalToConstant: 44))
        addConstraint(sv.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1))
        addConstraint(sv.centerXAnchor.constraint(equalTo: centerXAnchor))
        addConstraint(sv.centerYAnchor.constraint(equalTo: centerYAnchor))
        
        for field in fields {
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: field.frame.height))
            field.leftView = paddingView
            field.leftViewMode = .always
        }
        
        let bigScreen = (LayoutHelper.phoneScreenSize == .normal || LayoutHelper.phoneScreenSize == .plus)
        let textInset = CGPoint(x: bigScreen ? 8 : 4, y:0)
        let font = UIFont(name: "CourierNewPSMT", size: bigScreen ? 18 : 14)
        
        for textField in fields {
            textField.text = ""
            textField.delegate = self
            textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
            textField.font = font
            if let insetTextField = textField as? TextFieldWithInset {
                insetTextField.textContentInset = textInset
            }
        }
        
        fields.first?.becomeFirstResponder()
    }
    
    private func createTF(_ sv: UIStackView) -> UITextField {
        let tf = UITextField(frame: .zero)
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.autocapitalizationType = .allCharacters
        tf.autocorrectionType = .no
        sv.addArrangedSubview(tf)
        return tf
    }
    
    @objc private func textFieldDidChange() {
        propagateCodeChanged()
    }
    
    private func propagateCodeChanged() {
        delegate?.codeChanged(code: buildCode())
    }
    
    public func textField(_ tf: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if tf == fields.first && isEmptyCode && range.location == 0 && PA2OtpUtil.validateActivationCode(string) {
            pasteFullCode(code:string)
            return false
        }
        // check delete
        if string.isEmpty && range.length > 0 {
            return true
        }
        let (validChar, correctedString) = validateAndCorrectCharacters(string)
        if !validChar {
            if string != "-" {
                // character is not dash, we can blink with the text field
                errorBlink(textField: tf)
            }
            return false
        }
        
        let currString = (tf.text ?? "") as NSString
        let nextString = currString.replacingCharacters(in: range, with: correctedString)
        
        let oldLength = tf.text?.lengthOfBytes(using: .ascii) ?? 0
        let newLength = correctedString.lengthOfBytes(using: .ascii)
        
        if oldLength + newLength <= segmentLength {
            tf.text = nextString
            if oldLength + newLength == segmentLength {
                focusNextTextField(current: tf)
            }
            if let position = tf.position(from: tf.endOfDocument, offset: 0) {
                tf.selectedTextRange = tf.textRange(from: position, to: position)
            }
            // nothing to focus, try to check code
            propagateCodeChanged()
        }
        return false
    }
    
    private func errorBlink(textField: UITextField, count: Int = 2) {
        
        let duration: TimeInterval = 0.08
        
        textField.layer.removeAllAnimations()
        
        UIView.animate(withDuration: duration, animations: {
            textField.layer.opacity = 0.5
        }, completion: { complete in
            guard complete else {
                return
            }
            UIView.animate(withDuration: duration, animations: {
                textField.layer.opacity = 1
            }) { completeBack in
                if completeBack && count > 1 {
                    self.errorBlink(textField: textField, count: count - 1)
                }
            }
        })
    }
    
    private func validateAndCorrectCharacters(_ string: String) -> (Bool, String) {
        var result : String = ""
        var success = true
        for codepoint in string.unicodeScalars {
            let newCodepoint = PA2OtpUtil.validateAndCorrectTypedCharacter(codepoint.value)
            if newCodepoint != 0 {
                let corrected = UnicodeScalar(newCodepoint)!
                result.append(Character(corrected))
            } else {
                success = false
                break
            }
        }
        return (success, result)
    }
    
    private func focusNextTextField(current: UITextField) {
        
        guard let idx = fields.firstIndex(of: current) else {
            return
        }
        
        if idx < fields.count - 1 {
            let next = fields[idx + 1]
            next.becomeFirstResponder()
            if let position = next.position(from: next.endOfDocument, offset: 0) {
                next.selectedTextRange = next.textRange(from: position, to: position)
            }
        } else if idx == fields.count - 1 {
            afterFilledResponder?.becomeFirstResponder()
        }
    }
    
    private func pasteFullCode(code: String) {
        // full code pasted to the first field
        let components = code.components(separatedBy: "-")
        
        for i in 0..<components.count {
            fields[i].text = components[i]
        }
        
        // new cursor position
        if let position = tf4.position(from: tf4.endOfDocument, offset: 0) {
            tf4.selectedTextRange = tf4.textRange(from: position, to: position)
        }
        tf1.resignFirstResponder()
        propagateCodeChanged()
    }
}
