//
//  UIViiewController+Extensions.swift
//  HOLA
//
//  Created by Клим Бакулин on 27.02.2023.
//

import Foundation
import UIKit

extension UIViewController {
    
    func createCustomTitleView(contactName: String, contactMail: String, contactImage: UIImageView?) -> UIView {
         let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: 280, height: 41)
        
        
        let imageContact = UIImageView(frame: CGRect(x: 5, y: 0, width: 40, height: 40))
        if let contactImage = contactImage {
            imageContact.image = contactImage.image
            imageContact.layer.cornerRadius = imageContact.frame.height / 2
            imageContact.clipsToBounds = true
            imageContact.contentMode = .scaleAspectFill
        }
        view.addSubview(imageContact)
            

        
        
        let nameLabel = UILabel()
        nameLabel.text = contactName
        nameLabel.frame = CGRect(x: 55, y: 0, width: 220, height: 20)
        nameLabel.font = UIFont.systemFont(ofSize: 16)
        view.addSubview(nameLabel)
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = contactMail
        descriptionLabel.frame = CGRect(x: 55, y: 21, width: 220, height: 20)
        descriptionLabel.font = UIFont.systemFont(ofSize: 12)
        view.addSubview(descriptionLabel)
        
        return view
    }
    
}
