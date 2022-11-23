//
//  WalletConnectTableViewCell.swift
//  BlockIDTestApp
//
//  Created by Kuldeep Choudhary on 25/08/22.
//

import UIKit
import BlockIDSDK

class WalletConnectTableViewCell: UITableViewCell {

    @IBOutlet weak var dAppURL: UILabel!
    @IBOutlet weak var selectedCheckImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setupCell(item: ActiveSessionItem) {
        self.dAppURL.text = item.dappURL
    }
    
}
