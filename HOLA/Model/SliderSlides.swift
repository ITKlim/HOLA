//
//  SliderSlides.swift
//  HOLY
//
//  Created by Клим Бакулин on 11.12.2022.
//

import Foundation
import UIKit

class SliderSlides {
    
    func getSlides() -> [Slides]  {
        var slides: [Slides] = []
        
        let slide1 = Slides(id: 1, text: "Простой", image: UIImage(named: "slide1")!)
        let slide2 = Slides(id: 2, text: "Быстрый", image: UIImage(named: "slide2")!)
        let slide3 = Slides(id: 3, text: "Удобный", image: UIImage(named: "slide3")!)
        
        slides.append(slide1)
        slides.append(slide2)
        slides.append(slide3)
        
        return slides
    }
}
