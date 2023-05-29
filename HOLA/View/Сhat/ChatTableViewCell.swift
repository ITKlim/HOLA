//
//  ChatTableViewCell.swift
//  HOLA
//
//  Created by Клим Бакулин on 13.02.2023.
//

import UIKit

class ChatTableViewCell: UITableViewCell {
    
    @IBOutlet weak var parentView: UIView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var userMessage: UILabel!
    @IBOutlet weak var userTime: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userDayOfMonth: UILabel!
    
    static let reuseId = "ChatTableViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        settingCell()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //MARK: - Config Cell
    func configCell(email: String?, name: String?, message: String?, date: (String, String)?, avatar: UIImageView?) {
        self.userName.text = name
        if name == nil {
            self.userName.text = email
            self.userEmail.text = email
        } else {
            self.userName.text = name
            self.userEmail.text = email
        }
        self.userMessage.text = message
        self.userTime.text = date?.1
        self.userDayOfMonth.text = date?.0
        if avatar == nil {
            self.userImage.image = UIImage(named: "unnamed")
        } else {
            self.userImage.image = avatar?.image
        }
    }
    
    func settingCell() {
        parentView.layer.cornerRadius = 5
        userImage.layer.cornerRadius = userImage.frame.height / 2
    }
    
}
