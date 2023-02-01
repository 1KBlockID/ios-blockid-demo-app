//
//  UIImageExtension.swift
//  BlockIDTestApp
//
//  Created by Aditya Sharma on 12/10/22.
//

import Foundation
import UIKit

extension UIImage {
    class func getBitMapImage(with color: UIColor) -> UIImage? {
        
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(color.cgColor)
            context.fill(rect)
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image ?? nil
    }
}

