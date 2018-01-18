//
//  TextFieldNavigationDelegate.swift
//  explore-ios
//
//  Created by Andra on 06/11/2017.
//  Copyright © 2017 andrapop. All rights reserved.
//

import Foundation
import UIKit

protocol TextFieldNavigationDelegate{
    func changeResponder(current: RegistrationTextFieldView)
    func textFieldDidBeginEditing(in view: RegistrationTextFieldView, textField : UITextField)
    func textFieldDidEndEditing(in view: RegistrationTextFieldView)
    
}

extension TextFieldNavigationDelegate{
    func textFieldDidBeginEditing(in view: RegistrationTextFieldView, textField : UITextField){
        //method is not required.
    }
    
    func textFieldDidEndEditing(in view: RegistrationTextFieldView){
        //method is not required.
    }
}

extension TextFieldNavigationDelegate where Self:UIViewController{
    func changeResponder(current: RegistrationTextFieldView){
        let nextTag = current.tag + 1
        
        if let nextResponder = self.view.viewWithTag(nextTag) as? RegistrationTextFieldView{
            nextResponder.textField.becomeFirstResponder()
        }else{
            current.textField.resignFirstResponder()
        }
    }
}
