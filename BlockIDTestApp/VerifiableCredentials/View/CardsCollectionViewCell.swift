//
//  CardsCollectionViewCell.swift
//  BlockIDTestApp
//
//  Created by Sushil Tiwari on 08/10/22.
//

import UIKit

class CardsCollectionViewCell: UICollectionViewCell {
    
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
    
    // trigger update
    override func layoutSubviews() {
        if let cardView = self.viewWithTag(101) as? CardView {
            cardView.frame = CGRect(x: 15.0,
                                    y: 15.0,
                                    width: self.frame.size.width - 30.0,
                                    height: 190.0)
        }
    }
}

// MARK: - Extension: Private Methods -
extension CardsCollectionViewCell {
    // initialize and setup subviews
    private func setupView() {
        let cardView = CardView(frame: CGRect.zero)
        cardView.tag = 101
        self.addSubview(cardView)
    }
}
