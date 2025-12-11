//
//  UIView+Ext.swift
//  1Kosmos Demo
//
//  Created by Prasanna Gupta on 05/12/25.
//

import UIKit

@IBDesignable
extension UIView {
    @IBInspectable
    public var borderColor: UIColor? {
        get {
            if let color = self.layer.borderColor {
                return UIColor(cgColor: color)
            } else {
                return nil
            }
        } set (color) {
            self.layer.borderColor = color?.cgColor
        }
    }
    
    @IBInspectable
    public var borderWidth: CGFloat {
        get {
            return self.layer.borderWidth
        } set (borderWidth) {
            self.layer.borderWidth = borderWidth
        }
    }
}
