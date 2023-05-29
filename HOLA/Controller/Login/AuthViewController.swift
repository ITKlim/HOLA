//
//  AuthViewController.swift
//  HOLY
//
//  Created by Клим Бакулин on 11.12.2022.
//

import UIKit

class AuthViewController: UIViewController {
    
    var delegate: LoginViewControllerDelegate!
    var service = Servise.shared
    var checkField = CheckField.shared
    var tapGest: UITapGestureRecognizer?
    var userDefault = UserDefaults.standard
    var activityIndicator = UIActivityIndicatorView()
    
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var enterDidTapButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTapGest()
        setupField()
    }
    
    @IBAction func closeDidTapButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func authDidTupButton(_ sender: Any) {
        setupConstraintsActivityIndicator()
        enterDidTapButton.titleLabel?.isHidden = true
        activityIndicator.startAnimating()
        if checkField.validField(emailView, emailField), checkField.validField(passwordView, passwordField) {
            let authData = LoginField(email: emailField.text!, password: passwordField.text!)
            
            guard Connectivity.isConnectedToInternet() else { return alertInternetConnection() }
            
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self = self else { return }
                self.service.authInApp(authData) { [weak self] responce in
                    guard let self = self else { return }
                    DispatchQueue.main.async {
                        switch responce {
                        case .success:
                            self.userDefault.set(true, forKey: "isLogin")
                            self.delegate.startApp()
                            self.activityIndicator.stopAnimating()
                            self.enterDidTapButton.titleLabel?.isHidden = false
                        case .noVerify:
                            let alert = self.alerAction("Ошибка", "Вы не верифицировали свой email. Подтвердите через почту!")
                            let verefyBtn = UIAlertAction(title: "ОК", style: .cancel)
                            alert.addAction(verefyBtn)
                            self.present(alert, animated: true)
                            self.activityIndicator.stopAnimating()
                            self.enterDidTapButton.titleLabel?.isHidden = false
                        case .error:
                            let alert = self.alerAction("Ошибка", "Email или пароль неправильны!")
                            let verefyBtn = UIAlertAction(title: "ОК", style: .cancel)
                            alert.addAction(verefyBtn)
                            self.present(alert, animated: true)
                            self.activityIndicator.stopAnimating()
                            self.enterDidTapButton.titleLabel?.isHidden = false
                        }
                    }
                }
            }
        } else {
            let alert = self.alerAction("Ошибка", "Проверьте введенные данные")
            let verefyBtn = UIAlertAction(title: "ОК", style: .cancel)
            alert.addAction(verefyBtn)
            self.activityIndicator.stopAnimating()
            self.enterDidTapButton.titleLabel?.isHidden = false
            self.present(alert, animated: true)
        }
    }
    
    @objc func endEditing(){
        self.view.endEditing(true)
    }
    
    private func alerAction(_ header: String?, _ message: String?) -> UIAlertController {
        let alert = UIAlertController(title: header, message: message, preferredStyle: .alert)
        return alert
    }
    
    private func setupTapGest() {
        tapGest = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        mainView.addGestureRecognizer(tapGest!)
    }
    
    private func setupField() {
        emailField.attributedPlaceholder = NSAttributedString(
            string: "Email",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray]
        )
        passwordField.attributedPlaceholder = NSAttributedString(
            string: "Пароль",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray]
        )
    }
    
    private func alertInternetConnection() {
        let alertController = UIAlertController(title: "Нет подключения к сети", message: "Пожалуйста, проверьте подключение к сети и повторите попытку.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.activityIndicator.stopAnimating()
        self.enterDidTapButton.titleLabel?.isHidden = false
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func setupConstraintsActivityIndicator() {
        enterDidTapButton.addSubview(self.activityIndicator)
        self.activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.activityIndicator.centerXAnchor.constraint(equalTo: enterDidTapButton.centerXAnchor),
            self.activityIndicator.centerYAnchor.constraint(equalTo: enterDidTapButton.centerYAnchor)
        ])
    }
    
}
