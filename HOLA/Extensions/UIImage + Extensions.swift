//
//  UIView + Extensions.swift
//  HOLA
//
//  Created by Клим Бакулин on 27.04.2023.
//

import Foundation
import UIKit

extension UIImage {

    func isEqualToImage(_ image: UIImage) -> Bool {
        let data1 = self.pngData()
        let data2 = image.pngData()
        return data1 == data2
    }
    
}
