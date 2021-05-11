//
//  AccessoryView.swift
//  ios-kernel
//
//  Created by 1Kosmos Engineering
//  Copyright © 2021 1Kosmos. All rights reserved.
//

import Foundation
import UIKit

class AccessoryView: UIToolbar {
    
    var onNextCallback: ((_ sender : Any) -> Void)?

    @IBOutlet var _toolBar: UIToolbar!
    @IBOutlet weak var _btnNext: UIBarButtonItem!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
     }

     required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
     }
    
    func setupView() {
        Bundle.main.loadNibNamed("AccessoryView", owner: self, options: nil)
        _toolBar.sizeToFit()
        self.addDock(view: _toolBar)
    }
    
    func addBar(_ frame: CGRect) -> AccessoryView {
        self.frame = frame
        return self
    }
    
    @IBAction func onNextClick(_ sender: Any) {
        onNextCallback!(sender)
    }
    
    func setBtnTitle(_ title: String) {
        _btnNext.title = title
    }
    
    func addDock(view: UIView) {
        self.addSubview(view)
        view.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        self.translatesAutoresizingMaskIntoConstraints = true
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
}
