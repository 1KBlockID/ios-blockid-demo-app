//
//  EnrollmentTableViewCell.swift
//  BlockIDTestApp
//
//  Created by 1Kosmos Engineering
//  Copyright © 2021 1Kosmos. All rights reserved.
//

import Foundation
import UIKit
import BlockIDSDK

class EnrollmentTableViewCell: UITableViewCell {

    @IBOutlet weak var lblEnrollment: UILabel!
    
    public func setupCell(enrollment: Enrollments) {
        
        self.lblEnrollment.text = enrollment.rawValue
        switch enrollment {
        case .DeviceAuth:
            self.accessoryType = BlockIDSDK.sharedInstance.isDeviceAuthRegisterd() ? .checkmark : .none
        case .DriverLicense:
            self.accessoryType = BlockIDSDK.sharedInstance.isDLEnrolled() ? .checkmark : .none
        case .Passport1:
            self.accessoryType = BlockIDSDK.sharedInstance.isPassportEnrolled() ? .checkmark : .none
        case .Passport2:
            self.accessoryType = BlockIDSDK.sharedInstance.isPassportEnrolled() ? .checkmark : .none
        case .NationalID:
            self.accessoryType = BlockIDSDK.sharedInstance.isNationalIdEnrolled() ? .checkmark : .none
        case .LiveID:
            self.accessoryType = BlockIDSDK.sharedInstance.isLiveIDRegisterd() ? .checkmark : .none
        case .Pin:
            self.accessoryType = BlockIDSDK.sharedInstance.isPinRegistered() ? .checkmark : .none
        default:
            break
        }
        
    }

}
