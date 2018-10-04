//
//  Extensions.swift
//  MUNCHIEBOX
//
//  Created by Johnathan Chen on 6/7/18.
//  Copyright © 2018 Johnathan Chen. All rights reserved.
//

import Foundation
import UIKit

extension String {
    
    func toLengthOf(length:Int) -> String {
        if length <= 0 {
            return self
        } else if let to = self.index(self.startIndex, offsetBy: length, limitedBy: self.endIndex) {
            return self.substring(from: to)
            
        } else {
            return ""
        }
    }
}

//extension UIButton {
//    func setUpRadius(roundness corner: Int) {
//        self.layer.cornerRadius = CGFloat(corner)
//        self.clipsToBounds = true
//    }
//}

extension UIView {
    func setUpRadius(roundness corner: Int) {
        self.layer.cornerRadius = CGFloat(corner)
        self.clipsToBounds = true
    }
}

