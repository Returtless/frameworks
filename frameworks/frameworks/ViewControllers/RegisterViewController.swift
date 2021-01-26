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

extension RegisterViewController {
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(hideView(_:)), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showView(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        }

    @objc func hideView(_ notification: Notification) {
        self.view.isHidden = true
    }
    @objc func showView(_ notification: Notification) {
        self.view.isHidden = false
    }
}
