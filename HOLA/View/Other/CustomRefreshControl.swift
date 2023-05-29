//
//  CustomRefreshControl.swift
//  HOLY
//
//  Created by Клим Бакулин on 22.01.2023.
//

import UIKit

class CustomRefreshControl: UIRefreshControl {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        self.tintColor = .primaryColor
    }
    
}
