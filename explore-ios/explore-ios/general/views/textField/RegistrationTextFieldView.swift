//
//  RegistrationTextFieldView.swift
//  explore-ios
//
//  Created by Andra on 06/11/2017.
//  Copyright © 2017 andrapop. All rights reserved.
//

import Foundation
import UIKit

class RegistrationTextFieldView : UIView {
    var navigationDelegate: TextFieldNavigationDelegate?
    
    
    @IBOutlet var trailingStackViewConstraint: NSLayoutConstraint!
    
    @IBOutlet var leadingStackViewConstraint: NSLayoutConstraint!
    
    @IBOutlet var trailingErrorLabelConstraint: NSLayoutConstraint!
    @IBOutlet var leadingErrorLabelConstraint: NSLayoutConstraint!
    
    
    @IBInspectable var margin : Int = 32{
        didSet{
            trailingStackViewConstraint.constant = CGFloat(margin)
            trailingErrorLabelConstraint.constant = CGFloat(margin)
            leadingStackViewConstraint.constant = CGFloat(margin)
            leadingErrorLabelConstraint.constant = CGFloat(margin)
            
            view.layoutIfNeeded()
            
        }
    }
    
    @IBOutlet var errorLabel: UILabel!
    
    var isDisabled = false{
        didSet{
            if isDisabled{
                disableUserInteration()
            }else{
                enableUserInteration()
            }
        }
    }
    
    var textFieldText : String = ""{
        didSet{
            if textFieldText.characters.count > 0{
                label.text = content
                textField.text = textFieldText
            }
        }
    }
    
    @IBInspectable var content : String? {
        didSet{
            initView()
        }
    }
    
    @IBInspectable var isEmailKeyboard : Bool = false{
        didSet{
            if isEmailKeyboard{
                self.textField.keyboardType = .emailAddress
            }
        }
    }
    
    @IBOutlet var view: UIView!
    
    @IBInspectable var isSecured : Bool = false{
        didSet{
            if isSecured {
                textField.rightViewMode = UITextFieldViewMode.always
                
                let button = UIButton(type: .custom)
                button.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
                let passImage = UIImage(named: "pass-view")
                button.setImage(passImage, for: .normal)
                button.addTarget(self, action: #selector(passViewBtnPressed), for: .touchUpInside)
                textField.rightView = button
                
                textField.isSecureTextEntry = true
            }
        }
    }
    
    @IBOutlet var label: UILabel!
    @IBOutlet var textField: BottomBorderTextField!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let _ = Bundle.main.loadNibNamed("RegistrationTextFieldView", owner: self, options: nil)?[0] as! UIView
        self.addSubview(view)
        view.frame = self.bounds
        textField.delegate = self
    }
    
    func initView(){
        hideLabel()
    }
    
    @objc func passViewBtnPressed(_ sender: Any){
        //see-password icon is pressed, change field security only if there is some text
        if isSecured{
            if let count = textField.text?.characters.count, count > 0{
                textField.isSecureTextEntry = !textField.isSecureTextEntry
            }
        }
    }
    
    func hideLabel(){
        if isSecured{
            textField.isSecureTextEntry = false
        }
        label.text = " "
        guard let content = content else{
            assertionFailure("Text Content has not been set")
            return
        }
        textField.attributedPlaceholder = NSAttributedString(string: content, attributes: [NSAttributedStringKey.foregroundColor : UIColor.black])
    }
    
    private func disableUserInteration(){
        if let content = content{
            textField.isUserInteractionEnabled = false
            textField.attributedPlaceholder = NSAttributedString(string: content, attributes: [NSAttributedStringKey.foregroundColor : UIColor.lightGray])
            textField.borderColor = .lightGray
        }
    }
    
    private func enableUserInteration(){
        if let content = content{
            textField.isUserInteractionEnabled = true
            textField.attributedPlaceholder = NSAttributedString(string: content, attributes: [NSAttributedStringKey.foregroundColor : UIColor.black])
            textField.borderColor = .black
        }
    }
}

extension RegistrationTextFieldView: UITextFieldDelegate{
    //handle textfield navigation on "next" button being presse
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //handle label transition (fill label and hide placeholder)
        editingStarted()
        navigationDelegate?.textFieldDidBeginEditing(in: self, textField: textField)
    }
    
    public func editingStarted(){
        label.text = content
        textField.placeholder = ""
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //handle empty field
        navigationDelegate?.textFieldDidEndEditing(in: self)
        if let count = textField.text?.characters.count , count > 0 {
            //i do entered some text
        }else{
            hideLabel()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        navigationDelegate?.changeResponder(current: self)
        return false
    }
}

