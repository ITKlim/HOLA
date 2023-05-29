//
//  UICollectionView+Extensions.swift
//  HOLY
//
//  Created by Клим Бакулин on 17.01.2023.
//


import UIKit

extension UICollectionView {
    
    func reloadData(completion: @escaping ()->()) {
        UIView.animate(withDuration: 0, animations: {
            self.reloadData()
        }, completion: { _ in
            completion()
        })
    }
    
}
