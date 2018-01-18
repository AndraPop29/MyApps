//
//  SignUpViewController.swift
//  explore-ios
//
//  Created by Andra on 06/11/2017.
//  Copyright © 2017 andrapop. All rights reserved.
//

import UIKit
import MessageUI

class SignUpViewController: UIViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet var nameView: RegistrationTextFieldView!
    
    @IBOutlet var emailView: RegistrationTextFieldView!
    
    @IBOutlet var passwordView: RegistrationTextFieldView!
    
    @IBOutlet var confirmPasswordView: RegistrationTextFieldView!
    
    @IBOutlet var constraintTop: NSLayoutConstraint!
    
    
    var email : String?
    
    
    deinit {
        //remove VC from Notification center obervers
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if email != nil{
            self.emailView.textField.text = email
        }
        
        
        //add obversver for keyboard will show
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardAppeared(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        //add observer for keyboard will hide
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDissapear(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        
        //set password fields to secured
        passwordView.isSecured = true
        confirmPasswordView.isSecured = true
        
        
        //add navigation delegates
        nameView.navigationDelegate = self
        emailView.navigationDelegate = self
        passwordView.navigationDelegate = self
        confirmPasswordView.navigationDelegate = self
        
        //
        silenceWarnings()
    }
    
    @objc func keyboardAppeared(notification: NSNotification){
        //only needed for iPhone 5
        if self.view.frame.size.height < 660{
            
            //move content up if password view or confirmPasswordView is selected
            //move content up only if it was no moved before
            if passwordView.textField.isFirstResponder || confirmPasswordView.textField.isFirstResponder,
                self.constraintTop.constant == 1{
                moveContentUp()
            }
        }
    }
    
    @objc func keyboardWillDissapear(notification: NSNotification){
        //only needed for iPhone 5
        if self.view.frame.size.height < 660{
            //move content back down only if it is up
            if self.constraintTop.constant != 1{
                moveContentDown()
            }
        }
    }
    
    func moveContentDown(){
        
        //animate constraint
        self.constraintTop.constant = self.constraintTop.constant + 30
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func moveContentUp(){
        //animate constraint
        self.constraintTop.constant = self.constraintTop.constant - 30
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded()
            
        })
    }
    

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //hide keyboard if user touches outside textfield area
        
        nameView.textField.resignFirstResponder()
        emailView.textField.resignFirstResponder()
        passwordView.textField.resignFirstResponder()
        confirmPasswordView.textField.resignFirstResponder()
    }
    
    func silenceWarnings(){
        nameView.errorLabel.text = " "
        emailView.errorLabel.text = " "
        passwordView.errorLabel.text = " "
        confirmPasswordView.errorLabel.text = " "
    }
    
    func isValidEmail(testStr:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    @IBAction func submitButtonPressed(_ sender: Any) {
        
        silenceWarnings()
        
        guard let name = nameView.textField.text,
            name.characters.count > 0 else{
                nameView.errorLabel.text = "The field cannot be empty"
                return
        }
        
        guard let email = emailView.textField.text,
            email.characters.count > 0 else{
                emailView.errorLabel.text = "The field cannot be empty"
                return
        }
        
        if !isValidEmail(testStr: email){
            emailView.errorLabel.text = "The email doesn't have a correct format"
            return
        }
        
        guard let password = passwordView.textField.text,
            password.characters.count >= 6 else{
                passwordView.errorLabel.text = "The password needs to be at least 6 characters long"
                return
        }
        
        guard let confirmPasword = confirmPasswordView.textField.text,
            confirmPasword == password else{
                confirmPasswordView.errorLabel.text = "The introduced passwordds don't match"
                return
        }
        
        let mailComposeViewController = configuredMailComposeViewController(body: name)
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    @IBAction func returnToLoginPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func configuredMailComposeViewController(body: String) -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients(["andrapop291@gmail.com"])
        mailComposerVC.setSubject("Sending you an in-app e-mail...")
        mailComposerVC.setMessageBody("Welcome to explore, "+body, isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension SignUpViewController: TextFieldNavigationDelegate{
    func changeResponder(current: RegistrationTextFieldView) {
        //used in order to navigate to the next textField (or hide the keyboard on "Next" pressed if on the password\
        let nextTag = current.tag + 1
        
        if let nextResponder = self.view.viewWithTag(nextTag) as? RegistrationTextFieldView{
            nextResponder.textField.becomeFirstResponder()
        }else{
            current.textField.resignFirstResponder()
        }
    }
}
