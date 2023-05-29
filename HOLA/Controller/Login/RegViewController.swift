//
//  RegViewController.swift
//  HOLY
//
//  Created by Клим Бакулин on 11.12.2022.
//


import UIKit

class RegViewController: UIViewController {
    
    let service = Servise.shared
    var delegate: LoginViewControllerDelegate!
    var checkField = CheckField.shared
    var activityIndicator = UIActivityIndicatorView()
    var tapGest: UITapGestureRecognizer?
    
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var rePasswordField: UITextField!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var rePasswordView: UIView!
    @IBOutlet weak var regDidTapButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTapGest()
        setupField()
    }
    
    @IBAction func closeVCDidTapButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func regDidTapButton(_ sender: Any) {
        setupConstraintsActivityIndicator()
            guard Connectivity.isConnectedToInternet() else {
                return alertInternetConnection()
            }
            guard checkField.validField(emailView, emailField),
                  checkField.validField(passwordView, passwordField) else {
                return
            }
            if passwordField.text == rePasswordField.text {
                rePasswordView.backgroundColor = .white
                rePasswordField.backgroundColor = .white
                
                self.activityIndicator.startAnimating()
                self.regDidTapButton.titleLabel?.isHidden = true
                
                let loginField = LoginField(email: self.emailField.text!, password: self.passwordField.text!)
                
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    guard let self = self else { return }
                    self.service.createNewUser(loginField) { [weak self] result in
                        guard let self = self else { return }
                        DispatchQueue.main.async {
                            self.activityIndicator.stopAnimating()
                            self.regDidTapButton.titleLabel?.isHidden = false
                            switch result {
                            case .failure(let error):
                                print("Ошибка регистрации", error.localizedDescription)
                                let alert = UIAlertController(title: "Ошибка", message: error.localizedDescription, preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .default))
                                self.present(alert, animated: true)
                            case .success(_):
                                print("Успешно зарегистрировались")
                                self.service.confirmEmail()
                                let alert = UIAlertController(title: "Подвердите регистрацию!", message: "На вашу почту пришло письмо с ссылкой на подтверждение. Выполните подтверждение регистрации и сделайте вход в приложение", preferredStyle: .alert)
                                let okBtn = UIAlertAction(title: "ОК", style: .default) { _ in
                                    self.dismiss(animated: true)
                                }
                                alert.addAction(okBtn)
                                self.present(alert, animated: true)
                            }
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.rePasswordView.backgroundColor = .systemRed
                    self.rePasswordField.backgroundColor = .systemRed
                }
            }
    }
    
    @IBAction func authDidTapButton(_ sender: Any) {
        let strb = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = strb.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else { return }
        navigationController?.show(vc, sender: self)
    }
    
    private func setupTapGest(){
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
        rePasswordField.attributedPlaceholder = NSAttributedString(
            string: "Повторите пароль",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        
    }
    private func alertInternetConnection() {
        let alertController = UIAlertController(title: "Нет подключения к сети", message: "Пожалуйста, проверьте подключение к сети и повторите попытку.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.activityIndicator.stopAnimating()
        self.regDidTapButton.titleLabel?.isHidden = false
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func setupConstraintsActivityIndicator() {
        regDidTapButton.addSubview(self.activityIndicator)
        self.activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.activityIndicator.centerXAnchor.constraint(equalTo: regDidTapButton.centerXAnchor),
            self.activityIndicator.centerYAnchor.constraint(equalTo: regDidTapButton.centerYAnchor)
        ])
    }
    
    @objc func endEditing(){
        self.view.endEditing(true)
    }
    
    
}
