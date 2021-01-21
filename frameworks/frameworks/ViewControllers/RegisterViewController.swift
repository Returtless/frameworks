//
//  RegisterViewController.swift
//  frameworks
//
//  Created by Владислав Лихачев on 21.01.2021.
//

import UIKit

class RegisterViewController: UIViewController {

    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    @IBAction func saveButtonWasTapped(_ sender: UIButton) {
        let user = User()
        user.login = loginTextField.text
        user.password = passwordTextField.text
        RealmService.saveDataToRealm(user)
    }

}
