//
//  LoginViewController.swift
//  frameworks
//
//  Created by Владислав Лихачев on 21.01.2021.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var registerLabel: UILabel!
    
    var loginRouter: LoginRouter!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginRouter = LoginRouter(vc: self)
        configureTextFields()
        configureRegisterLabel()
    }
    
    @IBAction func loginButtonWasTapped(_ sender: UIButton) {
        UserDefaults.standard.set(true, forKey: "isLogin")
        guard let login = loginTextField.text, let password = passwordTextField.text else {
            loginTextField.isError(baseColor: UIColor.gray.cgColor, numberOfShakes: 3, revert: true)
            return
        }
        guard !login.isEmpty else {
            loginTextField.isError(baseColor: UIColor.gray.cgColor, numberOfShakes: 3, revert: true)
            return
        }

        guard !password.isEmpty else {
            passwordTextField.isError(baseColor: UIColor.gray.cgColor, numberOfShakes: 3, revert: true)
            return
        }
        authorize(login: login, password: password)
    }
    
    func configureTextFields(){
        loginTextField.setBottomBorderOnlyWith(color: UIColor.gray.cgColor)
        passwordTextField.setBottomBorderOnlyWith(color: UIColor.gray.cgColor)
    }
    
    func configureRegisterLabel(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(registerTap))
        registerLabel.isUserInteractionEnabled = true
        registerLabel.addGestureRecognizer(tap)
        let attributedString = NSMutableAttributedString(string: "Зарегистрироваться")
        attributedString.addAttribute(.link, value: "Зарегистрироваться", range: NSRange(location: 0, length: 18))
        registerLabel.attributedText = attributedString
    }
    
    @objc
    func registerTap(sender:UITapGestureRecognizer) {
        loginRouter.toRegister()
    }
    

    func authorize(login : String, password : String){
        
        let dataFromRealm : [User] = RealmService.getDataFromRealm(with: "login == '\(login)' AND password == '\(password)'")
        
        if dataFromRealm.isEmpty {
            self.showAlert(title: "Ошибка авторизации!", message: "Неправильные логин/пароль")
        } else {
            loginRouter.toMain()
        }
    }
    
}

extension UITextField {
    func setBottomBorderOnlyWith(color: CGColor) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = color
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
    }
    
    func isError(baseColor: CGColor, numberOfShakes shakes: Float, revert: Bool) {
        let animation: CABasicAnimation = CABasicAnimation(keyPath: "shadowColor")
        animation.fromValue = baseColor
        animation.toValue = UIColor.red.cgColor
        animation.duration = 0.4
        if revert { animation.autoreverses = true } else { animation.autoreverses = false }
        self.layer.add(animation, forKey: "")

        let shake: CABasicAnimation = CABasicAnimation(keyPath: "position")
        shake.duration = 0.07
        shake.repeatCount = shakes
        if revert { shake.autoreverses = true  } else { shake.autoreverses = false }
        shake.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 10, y: self.center.y))
        shake.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + 10, y: self.center.y))
        self.layer.add(shake, forKey: "position")
    }
}

final class LoginRouter: BaseRouter {
    
    
    func toMain() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
        push(vc: vc)
    }
    func toRegister() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "RegisterViewController") as! RegisterViewController
        present(vc: vc)
    }
}

extension LoginViewController {
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
