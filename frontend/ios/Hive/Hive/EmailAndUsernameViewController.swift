//
//  EmailViewController.swift
//  Hive
//
//  Created by Chuck Onwuzuruike on 4/5/20.
//  Copyright © 2020 Chuck Onwuzuruike. All rights reserved.
//

import UIKit

class EmailAndUsernameViewController : UIViewController, SignInPageFragment {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    private var signInDelegate: SignInDelegate?
    private let client: ServerClient = ServerClient()
    private var args: [String:Any]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setSignInPageDelegate(delegate: SignInDelegate) {
        signInDelegate = delegate
    }
    
    func setArgs(args: [String:Any]) {
        self.args = args
    }
    
    @IBAction func nextBnAction(_ sender: UIButton) {
        let username = usernameTextField.text!.trimmingCharacters(in: .whitespaces)
        let email = emailTextField.text!.trimmingCharacters(in: .whitespaces)
        if (!UtilityBelt.isValidUsername(username: username) ||
            !UtilityBelt.isValidEmail(email: email)) {
            showAlert(message: "Invalid username or email")
            return
        }
        disableUserActivity()
        print("Username: " + username)
        print("Email: " + email)
        client.createNewUser(username: username, email: email, completion: createNewUserCompletion, notes: ["username": username, "email": email])
    }
    
    @IBAction func goBackBnAction(_ sender: UIButton) {
        self.signInDelegate!.goLogInOrSignUp()
    }
    
    private func createNewUserCompletion(responseOr: StatusOr<Response>, notes: [String:Any]?) {
        if (responseOr.hasError()) {
            showInternalServerErrorAlert()
            return
        }
        let response = responseOr.get()
        if (!response.ok()) {
            showAlert(title: "Oh...", message: response.serverMessage)
            return
        }
        let username = notes!["username"] as! String
        let email = notes!["email"] as! String
        signInDelegate!.saveLogInData(username: username, email: email, isSignUpVerified: false)
        DispatchQueue.main.async {
            self.signInDelegate?.goEnterPinCode(
                args: ["username": username, "email": email])
        }
    }
    
}
