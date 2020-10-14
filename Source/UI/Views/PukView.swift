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

@objc public protocol PukViewDelegate: class {
    func pukChanged(puk: String)
}

public class PukView: UIView, UITextFieldDelegate {
    
    private weak var tf1: UITextField!
    private weak var tf2: UITextField!
    private var fields: [UITextField] { return [tf1, tf2] }
    
    @IBOutlet weak var delegate: PukViewDelegate?
    
    private let segmentLength = 5
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
    }
    
    // MARK: - public API
    
    public func prepareComponent(uiDataProvider: ActivationUIDataProvider) {
        createTextFields()
        tf1.applyTextFieldStyle(uiDataProvider.uiTheme.enterCodeScene.puk)
        tf2.applyTextFieldStyle(uiDataProvider.uiTheme.enterCodeScene.puk)
    }
    
    public func buildPUK() -> String {
        return (tf1.text ?? "") + (tf2.text ?? "")
    }
    
    public var isCodeFilled: Bool {
        return fields.allSatisfy { $0.text?.count == segmentLength }
    }
    
    public override func becomeFirstResponder() -> Bool {
        return tf1.becomeFirstResponder()
    }
    
    // MARK: - private helpers and delegates
    
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
        
        addSubview(sv)
        addConstraint(sv.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5))
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
    
    @objc private func textFieldDidChange() {
        propagateCodeChanged()
    }
    
    private func propagateCodeChanged() {
        delegate?.pukChanged(puk: buildPUK())
    }
    
    private func createTF(_ sv: UIStackView) -> UITextField {
        let tf = UITextField(frame: .zero)
        tf.keyboardType = .numberPad
        tf.autocorrectionType = .no
        tf.translatesAutoresizingMaskIntoConstraints = false
        sv.addArrangedSubview(tf)
        return tf
    }
    
    public func textField(_ tf: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string.isEmpty {
            return true
        }
        
        let currString = (tf.text ?? "") as NSString
        let nextString = currString.replacingCharacters(in: range, with: string)
        
        let oldLength = tf.text?.count ?? 0
        let replaceLength = string.count
        let rangeLenght = range.length
        
        let newLength = oldLength - rangeLenght + replaceLength
        
        if newLength > segmentLength {
            return false
        }
        
        if Int(string) == nil {
            return false
        }
        
        if tf === tf1 && nextString.count == segmentLength {
            tf.text = nextString
            tf2.becomeFirstResponder()
            return false
        }
        
        return true
    }
}
