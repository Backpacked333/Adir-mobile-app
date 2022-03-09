//
//  CustomTextFieldView.swift
//  AdirApp
//
//  Created by Vladyslav Kozlovskyi on 03.11.2021.
//

import UIKit

final class CustomTextFieldView: BaseXibLoadableView {
    
    @IBOutlet private var mainIcon: UIImageView!
    @IBOutlet private var mainTextField: UITextField! {
        didSet{
            mainTextField.delegate = self
        }
    }
    @IBOutlet private var mainPlaceholderLabel: UILabel!
    
    public var getText: String {
        mainTextField.text ?? ""
    }
    
    public func setupField(icon: UIImage, placeholder: String) {
        mainIcon.image = icon
        mainTextField.text = ""
        mainPlaceholderLabel.text = placeholder
        mainTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
    }
    
    public func fillTextField(text: String) {
        mainPlaceholderLabel.isHidden = !text.isEmpty
        mainTextField.text = text
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        mainPlaceholderLabel.isHidden = !(textField.text?.isEmpty ?? true)
    }
}

extension CustomTextFieldView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        mainTextField.resignFirstResponder()
        return true
    }
}
