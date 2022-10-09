//
//  CardView.swift
//  BlockIDTestApp
//
//  Created by Sushil Tiwari on 06/10/22.
//

import UIKit

// default card types
enum CardType: String {
    case none = "none"
    case identity_dl = "identity_dl"
    case employee_card = "employee_card"
}

class CardView: UIView {
    
    // imageview to display logo
    var imageView: UIImageView?
    
    // label to display issuer name
    var issuerText: UILabel?
    
    // label to display type of verified card
    var typeText: UILabel?
    
    // set shadowOffsetWidth
    var shadowOffsetWidth: CGFloat = 0.0 {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    // set shadowOffsetHeight
    var shadowOffsetHeight: CGFloat = 0.0 {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    // set shadowRadius
    var shadowRadius: CGFloat = 6.0 {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    // set cornerRadius
    var cornerRadius: CGFloat = 10.0 {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    // set borderWidth
    var borderWidth: CGFloat = 4.0  {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    // set shadowOpacity
    var shadowOpacity: Float = 0.0 {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    // set maskToBounds
    var maskToBounds: Bool = false {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    // set shadowColor
    var shadowColor: UIColor = UIColor.gray {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    // set borderColor
    var borderColor: UIColor = UIColor.black {
        didSet {
            super.layer.borderColor = borderColor.cgColor
        }
    }
    
    // set backgroundColor
    override var backgroundColor: UIColor? {
        didSet {
            super.layer.backgroundColor = backgroundColor?.cgColor
        }
    }
    
    // set card type
    var type: CardType = .none {
        didSet {
            switch type {
            case .none:
                self.backgroundColor = UIColor.white
                self.borderColor = UIColor.black
                self.imageView?.image = nil
                self.issuerText?.text = ""
                self.typeText?.text = ""
            case .identity_dl:
                self.backgroundColor = UIColor(red: 0.933,
                                                     green: 0.0,
                                                     blue: 0.0,
                                                     alpha: 1.0)
                self.borderColor = UIColor(red: 0.827,
                                                 green: 0.094,
                                                 blue: 0.047,
                                                 alpha: 1.0)
            case .employee_card:
                self.backgroundColor = UIColor(red: 0.447,
                                                     green: 0.506,
                                                     blue: 0.91,
                                                     alpha: 1.0)
                self.borderColor = UIColor(red: 0.275,
                                                 green: 0.227,
                                                 blue: 0.565,
                                                 alpha: 1.0)
            }
            
            self.setNeedsLayout()
        }
    }
    
    // init method
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    // init method from xib/storyboard
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupView()
    }
    
    // trigger layout update
    override func layoutSubviews() {
        // update cardview appearance
        self.updateAppearance()
        
        // get frame size
        let rect = self.frame
        
        // default margin
        let xMargin = 20.0
        let yMargin = 20.0
        
        // setup imageview frame
        var imgViewRect = CGRect.zero
        imgViewRect.size.width = 25.0
        imgViewRect.size.height = 20.0
        imgViewRect.origin.x = xMargin
        imgViewRect.origin.y = yMargin
        self.imageView?.frame = imgViewRect
        
        // setup issuer frame
        var issuerRect = CGRect.zero
        issuerRect.size.width = rect.size.width - (2 * xMargin)
        issuerRect.size.height = 17.0
        issuerRect.origin.x = xMargin
        issuerRect.origin.y = rect.size.height - issuerRect.height - yMargin
        self.issuerText?.frame = issuerRect
        
        // setup typeText frame
        var typeTextRect = CGRect.zero
        typeTextRect.size.height = 15.0
        typeTextRect.origin.y = 22.0
        typeTextRect.origin.x = imgViewRect.origin.x + imgViewRect.size.width + xMargin
        typeTextRect.size.width = rect.size.width - typeTextRect.origin.x - xMargin
        self.typeText?.frame = typeTextRect
        
        // setup font, color and alignment
        // issuerText
        self.issuerText?.font = UIFont.systemFont(ofSize: 14.0,
                                              weight: UIFont.Weight.bold)
        self.issuerText?.textColor = UIColor.white
        self.issuerText?.textAlignment = .left
        
        // typeText
        self.typeText?.font = UIFont.systemFont(ofSize: 12.0,
                                              weight: UIFont.Weight.semibold)
        self.typeText?.textColor = UIColor.white
        self.typeText?.textAlignment = .right
        
    }
}

// MARK: - Extension: Private Methods -
extension CardView {
    // initialize and setup subviews
    private func setupView() {
        self.imageView = UIImageView(frame: CGRect.zero)
        self.addSubview(self.imageView!)
        
        self.issuerText = UILabel(frame: CGRect.zero)
        self.addSubview(self.issuerText!)
        
        self.typeText = UILabel(frame: CGRect.zero)
        self.addSubview(self.typeText!)
    }
    
    // update card view appearance
    private func updateAppearance() {
        self.layer.shadowOffset = CGSize(width: self.shadowOffsetWidth,
                                         height: self.shadowOffsetHeight)
        self.layer.shadowRadius = self.shadowRadius
        self.layer.cornerRadius = self.cornerRadius
        self.layer.borderWidth = self.borderWidth
        self.layer.shadowOpacity = self.shadowOpacity
        self.layer.masksToBounds = self.maskToBounds
        self.layer.shadowColor = self.shadowColor.cgColor
        self.layer.borderColor = self.borderColor.cgColor
    }
}
