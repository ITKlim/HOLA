//
//  ChangeInfoViewController.swift
//  HOLA
//
//  Created by Клим Бакулин on 07.02.2023.
//

import UIKit
import MessageKit

class ChangeProfileViewController: UIViewController {
    
    let service = Servise.shared
    let defaults = UserDefaults.standard
    
    var userName = String()
    var currentUser = User()
    var avatar = UIImageView()
    var userNameCallBack: ((String?) -> Void)?
    var userAvatarCallBack: ((UIImageView?) -> Void)?
    
    @IBOutlet weak var userAvatar: AvatarView!
    
    @IBOutlet weak var userNameTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.userAvatar.image = avatar.image
        
        service.getSelfName { [weak self] name in
            guard let self = self else {return}
            self.userNameTF.text = name.name
            
        }
        userNameTF.text = userName
        let rightButton = UIBarButtonItem.init(title: "Готово", style: .plain, target: self, action: #selector(didTapSaveButton(_:)))
        navigationItem.rightBarButtonItem = rightButton
    }
    
    @IBAction func changeUserAvatarDidTapButton(_ sender: Any) {
    
        
        DispatchQueue.main.async {
            let pickerController = UIImagePickerController()
            pickerController.sourceType = .photoLibrary
            pickerController.allowsEditing = true
            pickerController.delegate = self
            self.present(pickerController, animated: true)
        }
    }

    
    private func uploadToFileManager(avatar: UIImage?) {
        let image = avatar
        if let data = image?.pngData(),
           let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let fileURL = documentsDirectory.appendingPathComponent("avatar.png")
            
            do {
                try data.write(to: fileURL)
            } catch {
            }
        }
    }
    
    private func alertInternetConnection() {
        let alertController = UIAlertController(title: "Нет подключения к сети", message: "Пожалуйста, проверьте подключение к сети и повторите попытку.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc
    private func didTapSaveButton(_ sender: UIBarButtonItem) {
        guard Connectivity.isConnectedToInternet() else { return alertInternetConnection()}
        var user = OtherInfoOfUser()
        user.name = userNameTF.text
        self.defaults.set(user.name, forKey: "name")
        service.addInfo(info: user) { code in
            switch code {
            case .success(_):
                ()
            case .failure(let err):
                print(err.localizedDescription)
            }
    }
        self.userNameCallBack?(self.userNameTF.text)
        self.userAvatarCallBack?(self.userAvatar)
        self.uploadToFileManager(avatar:  self.userAvatar.image)
        self.navigationController?.popViewController(animated: true)
    }
}


extension ChangeProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.editedImage] as? UIImage {
                // Используем отредактированное изображение (только выбранную область)
                userAvatar.image = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                // Используем оригинальное изображение (весь снимок)
                userAvatar.image = originalImage
            }
        
        self.dismiss(animated: true)
        
        service.uploadPhoto(image: userAvatar.image!, photoImageView: self.userAvatar) { result in
            switch result {
                
            case .success(let url):
                print(url)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
}
