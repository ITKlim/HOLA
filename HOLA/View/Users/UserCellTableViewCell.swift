//
//  UserCellTableViewCell.swift
//  HOLY
//
//  Created by Клим Бакулин on 19.12.2022.
//

import UIKit

class UserCellTableViewCell: UITableViewCell {
    
    static let reuseId = "UserCellTableViewCell"
    
    @IBOutlet weak var parentView: UIView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        settingCell()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func settingCell() {
        parentView.layer.cornerRadius = 6
        userImage.layer.cornerRadius = userImage.frame.height / 2
    }
    
    func configCell(name: String, image: UIImageView?) {
        self.userName.text = name
        if let userAvatar = image {
            self.userImage.image = userAvatar.image
        } else {
            self.userImage.image = UIImage(named: "unnamed")
        }
    }
    
}
