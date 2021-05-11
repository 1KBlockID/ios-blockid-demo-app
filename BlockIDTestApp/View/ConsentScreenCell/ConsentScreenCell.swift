//
//  ConsentScreenCell.swift
//  BlockIDTestApp
//
//  Created by vaidehi hindlekar on 07/05/21.
//

import Foundation
import UIKit
import BlockIDSDK

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
