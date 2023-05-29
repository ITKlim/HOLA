//
//  SelfInfoViewController.swift
//  HOLY
//
//  Created by Клим Бакулин on 22.01.2023.
//

import UIKit

class ProfileViewController: UIViewController {
    
    let service = Servise.shared
    let defaults = UserDefaults.standard
    
    var currentUser = User()
    
    @IBOutlet weak var avatarUserImageView: UIImageView!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    let avatarUserFromFileManager: UIImageView? = nil
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let loadImageFromDirectory = loadImageFromDirectory()
        avatarUserImageView.image = loadImageFromDirectory
        let nameUser = defaults.string(forKey: "name") ?? ""
        let emailUser = defaults.string(forKey: "email") ?? ""
        service.getSelfName { [weak self] user in
            
            DispatchQueue.main.async {
                guard let self = self else { return }
                if user.name != nameUser {
                    self.defaults.set(user.name, forKey: "name")
                    self.nameLabel.text = user.name
                }
                
                if user.email != emailUser {
                    self.defaults.set(user.email, forKey: "email")
                    self.emailLabel.text = user.email
                }
                
                self.emailLabel.text = user.email
                self.currentUser.avatarURL = user.avatarURL
                
                if Connectivity.isConnectedToInternet() {
                    if let avatarURL = self.currentUser.avatarURL {
                        self.service.fetchUserAvatar(url: avatarURL) { imageView in
                            
                            if imageView == nil {
                                self.avatarUserImageView.image = self.loadImageFromDirectory()
                            } else {
                                self.avatarUserImageView.image = imageView?.image
                                self.uploadToFileManager(imageView: self.avatarUserImageView)
                            }
                        }
                    } else {
                        self.avatarUserImageView.image = nil
                        self.removeAvatarFileManager()
                    }
                } else {
                    print("no internet")
                }
            }
        }
        
        self.nameLabel.text = nameUser
        self.emailLabel.text = emailUser
        
        let leftButton = UIBarButtonItem.init(title: "Изм.", style: .plain, target: self, action: #selector(didTapChangeButton(_:)))
        navigationItem.leftBarButtonItem = leftButton
        
        let rightButton = UIBarButtonItem.init(title: "Выход", style: .plain, target: self, action: #selector(didTapExitButton(_:)))
        navigationItem.rightBarButtonItem = rightButton
        
    }
    
    private func uploadToFileManager(imageView: UIImageView?) {
        let image = imageView?.image
        if let data = image?.pngData(),
           let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let fileURL = documentsDirectory.appendingPathComponent("avatar.png")
            
            do {
                try data.write(to: fileURL)
                print("Avatar image saved successfully", documentsDirectory.path)
            } catch {
                print("Error saving avatar image: \(error.localizedDescription)")
            }
        }
    }
    
    
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    private func loadImageFromDirectory() -> UIImage? {
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let avatarURL = documentsDirectory.appendingPathComponent("avatar.png")
            if let avatarImage = UIImage(contentsOfFile: avatarURL.path) {
                return avatarImage
            }
        }
        return nil
    }
    
    private func removeAvatarFileManager(){
        let fileManager = FileManager.default
        let documentsURL = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let fileURL = documentsURL.appendingPathComponent("avatar.png")
        
        do {
            try fileManager.removeItem(atPath: fileURL.path)
            print("File deleted successfully", fileURL.path)
        } catch let error {
            print("Error deleting file: \(error)")
        }
        
    }
    
    
    @objc
    private func didTapExitButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Внимание", message: "Вы действительно хотите выйти?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Да", style: .destructive, handler: { (_) in
            guard let window = UIWindow.key else { return }
            UserDefaults.standard.isLogin = false
            self.removeAvatarFileManager()
            window.rootViewController = UINavigationController(rootViewController: LoginViewController())
        }))
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        
        self.present(alert, animated: true)
    }
    
    @objc
    private func didTapChangeButton(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ChangeInfoViewController") as! ChangeProfileViewController
        if let userName = currentUser.name {
            vc.userName = userName
            
        }
        
        vc.avatar.image = avatarUserImageView.image
        vc.userNameCallBack = { [weak self] textName in
            self?.nameLabel.text = textName
            
        }
        vc.userAvatarCallBack = { [weak self] avatarImage in
            self?.avatarUserImageView.image = avatarImage?.image
            
        }
        show(vc, sender: nil)
    }
}
