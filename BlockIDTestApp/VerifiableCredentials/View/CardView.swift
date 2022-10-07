//
//  CardView.swift
//  BlockIDTestApp
//
//  Created by Sushil Tiwari on 06/10/22.
//

import UIKit

enum CardType {
    case none
    case identity
    case employee
}

@IBDesignable
class CardView: UIView {
    
    @IBInspectable var cornerRadius: CGFloat = 0.0
    @IBInspectable var shadowOffsetWidth: Float = 0.0
    @IBInspectable var shadowOffsetHeight: Float = 0.0
    @IBInspectable var shadowColor: UIColor? = .clear
    @IBInspectable var shadowOpacity: Float = 0.0
    @IBInspectable var bkgroundColor: UIColor? = .clear
    
    var type: CardType = .none {
        didSet {
            switch type {
            case .none:
                self.layer.backgroundColor = UIColor.white.cgColor
                self.layer.borderColor = UIColor.black.cgColor
            case .identity:
                self.layer.backgroundColor = UIColor(red: 0.933,
                                                     green: 0.0,
                                                     blue: 0.0,
                                                     alpha: 1.0).cgColor
                self.layer.borderColor = UIColor(red: 0.827,
                                                 green: 0.094,
                                                 blue: 0.047,
                                                 alpha: 1.0).cgColor
            case .employee:
                self.layer.backgroundColor = UIColor(red: 0.447,
                                                     green: 0.506,
                                                     blue: 0.91,
                                                     alpha: 1.0).cgColor
                self.layer.borderColor = UIColor(red: 0.275,
                                                 green: 0.227,
                                                 blue: 0.565,
                                                 alpha: 1.0).cgColor
            }
        }
    }
    
//    override var frame: CGRect {
//        didSet {
//            var rect = CGRect.zero
//            rect.height = 190.0
//            rect.width = super.frame.size.width - 30.0
//            rect.x = ()
//            super.frame = _frame
//        }
//    }
    
    override func layoutSubviews() {
        self.layer.masksToBounds = false
        self.layer.cornerRadius = 10.0
        self.layer.borderWidth = 4.0
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        self.layer.shadowRadius = 6.0
        self.layer.shadowOpacity = 0.5
    }
}
