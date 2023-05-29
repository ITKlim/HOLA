//
//  Connectivity.swift
//  HOLA
//
//  Created by Клим Бакулин on 14.03.2023.
//

import Foundation
import Alamofire
import UIKit

class Connectivity {
    class func isConnectedToInternet() -> Bool {
            return NetworkReachabilityManager()?.isReachable ?? false
        }
}
