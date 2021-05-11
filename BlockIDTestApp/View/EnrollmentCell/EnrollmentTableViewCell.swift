//
//  EnrollmentTableViewCell.swift
//  BlockIDTestApp
//
//  Created by vaidehi hindlekar on 04/05/21.
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
        case .Passport:
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
