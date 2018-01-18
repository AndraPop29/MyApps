//
//  LoginViewController.swift
//  explore-ios
//
//  Created by Andra on 06/11/2017.
//  Copyright © 2017 andrapop. All rights reserved.
//

import UIKit
import FirebaseAuth
import MBProgressHUD

struct KeychainConfiguration {
    static let serviceName = "TouchMeIn"
    static let accessGroup: String? = nil
}

class LoginViewController: UIViewController, TextFieldNavigationDelegate{
    
    @IBOutlet weak var registerNowStackView: UIStackView!
    @IBOutlet weak var passwordView: RegistrationTextFieldView!
    @IBOutlet weak var emailView: RegistrationTextFieldView!
    
    var alert : UIAlertController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //add target for view tap, to dismiss keyboard
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard(_:)))
        self.view.addGestureRecognizer(tapRecognizer)
        
        //Setting up password and email fields
        passwordView.navigationDelegate = self
        emailView.navigationDelegate = self
        passwordView.content = "PASSWORD"
        passwordView.isSecured = true
        emailView.content = "EMAIL"
        
        if let email = UserDefaults.standard.string(forKey: "email") {
            emailView.textField.text = email
            
            let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName,
                                                    account: email,
                                                    accessGroup: KeychainConfiguration.accessGroup)
            let pass = try? passwordItem.readPassword()
            passwordView.textField.text = pass
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func validateEmailAndPassword(email: String, password: String) -> Bool{
        if email.count == 0{
            emailView.errorLabel.text = "Please introduce a email address"
            return false
        }
        
        if !isValidEmail(testStr: email) {
            emailView.errorLabel.text = "The email address is not valid"
            return false
        }
        
        if password.count < 6{
            passwordView.errorLabel.text = "The password must be at least 6 characters long"
            return false
        }
        return true
        
    }
    
    @IBAction func loginButtonClicked(_ sender: Any) {
        //silence error labels
        emailView.errorLabel.text = " "
        passwordView.errorLabel.text = ""
        
        guard let email = emailView.textField.text,
            let password = passwordView.textField.text else{
                assertionFailure()
                return
        }
        
        if !validateEmailAndPassword(email: email, password: password) {
            return
        }
//        let hud = MBProgressHUD()
//        MBProgressHUD.show(hud)
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        Auth.auth().signIn(withEmail: email, password: password, completion: {
            user,error in
            
            //handle errors and present them
            if let error = error{
                print(error.localizedDescription)
                if error.localizedDescription.contains("There is no user record corresponding to this identifier") {
                    //if no email registerd -> perform segue to sign up
                    let alertController = UIAlertController(title: "Authentication error", message: "There is no user record corresponding to this identifier", preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                    return
                }
                if error.localizedDescription.contains("The email address is badly formatted"){
                    self.emailView.errorLabel.text = "The email address is badly formatted"
                }
                if error.localizedDescription.contains("The password is invalid"){
                    self.passwordView.errorLabel.text = "The email address is badly formatted"
                }
                if error.localizedDescription.contains("Network error"){
                    let alertController = UIAlertController(title: "Network error", message: "Verify if you are connected to the internet", preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
                MBProgressHUD.hide(for: self.view, animated: true)
                return
            }
            
            self.saveToUserDefaults(email: email, password: password)
            UserDataManager.shared.retrieve(withEmail: (Auth.auth().currentUser?.email!)!).then {
                user -> Void in
                UserDefaults.standard.set((user?.role)!, forKey: "role")
                UserDefaults.standard.set((user?.Id)!, forKey: "userId")
                if let mainViewController = self.storyboard?.instantiateViewController(withIdentifier: "tabBarController") as? UITabBarController {
                    //self.navigationController?.pushViewController(mainViewController, animated: true)
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.window?.rootViewController = mainViewController
                    
                }
                }.catch { error in
                    assertionFailure("User retrieval error")
            }
            
           
        })
        
    }
    
    func saveToUserDefaults(email : String, password: String) {
        let hasLoginKey = UserDefaults.standard.bool(forKey: "hasLoginKey")
        if hasLoginKey {
            return
        }
        do {
            UserDefaults.standard.setValue(email, forKey: "email")
            // This is a new account, create a new keychain item with the account name.
            let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName,
                                                    account: email,
                                                    accessGroup: KeychainConfiguration.accessGroup)
            
            // Save the password for the new item.
            try passwordItem.savePassword(password)
        } catch {
            fatalError("Error updating keychain - \(error)")
        }
        
        UserDefaults.standard.set(true, forKey: "hasLoginKey")
    }
    
   
    
    @objc func hideKeyboard(_ sender : Any){
        emailView.textField.resignFirstResponder()
        passwordView.textField.resignFirstResponder()
    }
    
    
}

