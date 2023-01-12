//
//  ConsentScreenCell.swift
//  BlockIDTestApp
//
//  Created by 1Kosmos Engineering
//  Copyright © 2021 1Kosmos. All rights reserved.
//

import Foundation
import UIKit
import BlockID

class ConsentScreenCell: UITableViewCell {
    
    @IBOutlet weak var _lblValue: UILabel!
    @IBOutlet weak var _lblTitle: UILabel!
    
    // MARK:-
    func setupCell(dataSetup: UserConsentInfoTVCDataSetup?) {
        guard let dataSetupUW = dataSetup else { return }
        _lblTitle.text = dataSetupUW.scopeName
        _lblValue.text = dataSetupUW.scopeValue
    }
}
