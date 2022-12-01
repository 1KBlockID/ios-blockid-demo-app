//
//  CustomActivityIndicator.swift
//  ios-kernel
//
//  Created by Prasanna Gupta on 1/12/22.
//  Copyright © 2020 1Kosmos. All rights reserved.
//

import Foundation
import UIKit

class CustomActivityIndicator: UIView {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var imgActivity: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
     }

     required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
     }
    
    func setupView() {
        Bundle.main.loadNibNamed("CustomActivityIndicator", owner: self, options: nil)
        self.contentView.backgroundColor = .clear
        self.addSubview(contentView)
    }
    
    func startAnimating() {
        isHidden = false
        rotate()
    }

    func stopAnimating() {
        isHidden = true
        removeRotation()
    }

    private func rotate() {
        let rotation: CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(value: Double.pi * 2)
        rotation.duration = 0.8
        rotation.isCumulative = true
        rotation.repeatCount = Float.greatestFiniteMagnitude
        self.imgActivity.layer.add(rotation, forKey: "rotationAnimation")
    }

    private func removeRotation() {
         self.imgActivity.layer.removeAnimation(forKey: "rotationAnimation")
    }
}
