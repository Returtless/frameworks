//
//  LoginViewController.swift
//  frameworks
//
//  Created by Владислав Лихачев on 21.01.2021.
//

import UIKit
import RxSwift
import RxCocoa

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var registerLabel: UILabel!
    
    @IBOutlet weak var loginButton: UIButton!
    var loginRouter: LoginRouter!
    var onTakePicture: ((UIImage) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginRouter = LoginRouter(vc: self)
        configureTextFields()
        configureRegisterLabel()
        configureLoginBindings()
    }
    @IBAction func takePicture(_ sender: UIButton) {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else { return }
        // Создаём контроллер и настраиваем его
        let imagePickerController = UIImagePickerController()
        // Источник изображений: камера
        imagePickerController.sourceType = .photoLibrary
        // Изображение можно редактировать
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        
        // Показываем контроллер
        present(imagePickerController, animated: true)
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
    
    func configureLoginBindings() {
        Observable.combineLatest(
            loginTextField.rx.text,
            passwordTextField.rx.text
        ).map { login, password in
            return !(login ?? "").isEmpty && (password ?? "").count >= 3
        }.bind { [weak loginButton] inputFilled in
            loginButton?.isEnabled = inputFilled
            loginButton?.setTitleColor(inputFilled ? UIColor.black : UIColor.gray, for: .normal)
        }
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
            loginRouter.toMap()
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
    
    func toMap(image : UIImage? = nil) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
        vc.img = image
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


extension LoginViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true) { [weak self] in
            guard let img = self?.extractImage(from: info) else  { return }
            //сохраняем в галерею
            UIImageWriteToSavedPhotosAlbum(img, self, #selector(self?.image(_:didFinishSavingWithError:contextInfo:)), nil)
            //открываем карту
            self?.loginRouter.toMap(image: img)
        }
    }
    
    private func extractImage(from info: [UIImagePickerController.InfoKey: Any]) -> UIImage? {
        if let image = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.editedImage.rawValue)] as? UIImage {
            return image
        } else if let image = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.originalImage.rawValue)] as? UIImage {
            return image
        } else {
            return nil
        }
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            showAlert(title: "Ошибка сохранения", message: error.localizedDescription)
        } else {
            showAlert(title: "Успешно!", message: "Изображение сохранено в галерею!")
        }
    }
}
