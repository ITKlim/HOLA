//
//  SlideCollectionViewCell.swift
//  HOLY
//
//  Created by Клим Бакулин on 10.12.2022.
//

import UIKit

class SlideCollectionViewCell: UICollectionViewCell {
    
    static let reuseId = "SlideCollectionViewCell"
    
    @IBOutlet weak var descriptionText: UILabel!
    @IBOutlet weak var slideImage: UIImageView!
    @IBOutlet weak var regBtn: UIButton!
    @IBOutlet weak var autBtn: UIButton!
    
    var delegate: LoginViewControllerDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(slide: Slides) {
        slideImage.image = slide.image
        descriptionText.text = slide.text
        if slide.id == 3 {
            regBtn.isHidden = false
            autBtn.isHidden = false
        }
    }
    
    @IBAction func regBtnClick(_ sender: Any) {
        delegate.openRegVC()
    }
    
    @IBAction func authBtnClick(_ sender: Any) {
        delegate.openAuthVC()
    }
    
}
