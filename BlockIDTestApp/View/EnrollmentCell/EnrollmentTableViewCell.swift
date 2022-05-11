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
    weak var controllerObj:EnrollMentViewController?
    var liveID = Enrollments.LiveID
    
    @IBOutlet weak var lblEnrollment: UILabel!
    
    public func setupCell(enrollment: Enrollments) {
        
        switch enrollment {
        case .AddUser:
            self.lblEnrollment.text = enrollment.rawValue
            if let linkedUserAccounts = BlockIDSDK.sharedInstance.getLinkedUserAccounts().linkedUsers, linkedUserAccounts.count > 0 {
                
                if let tagNCommunity = (linkedUserAccounts[0].origin.name != nil && !(linkedUserAccounts[0].origin.name?.isEmpty ?? false)) ?
                linkedUserAccounts[0].origin.name :
                        linkedUserAccounts[0].origin.community {
                    if let tag = linkedUserAccounts[0].origin.tag {
                        let tenatInfo = tag + " | " + tagNCommunity
                        self.lblEnrollment.text = linkedUserAccounts[0].userId + "\n" + tenatInfo
                    }

                } else {
                    self.lblEnrollment.text = linkedUserAccounts[0].userId
                }
                self.accessoryType = .checkmark
            } else {
                self.accessoryType = .none
            }
        case .DeviceAuth:
            self.lblEnrollment.text = enrollment.rawValue
            self.accessoryType = BlockIDSDK.sharedInstance.isDeviceAuthRegisterd() ? .checkmark : .none
        case .DriverLicense:
            let docId = controllerObj?.getDocumentID(docIndex: 1 ,type: .DL ,category: .Identity_Document)
            self.lblEnrollment.text = enrollment.rawValue+"(#"+(docId ?? "")+")"
            self.accessoryType = (docId != nil) ? .checkmark : .none
        case .Passport1:
            let docId = controllerObj?.getDocumentID(docIndex: 1 ,type: .PPT ,category: .Identity_Document)
            self.lblEnrollment.text = enrollment.rawValue+"(#"+(docId ?? "")+")"
            self.accessoryType = (docId != nil) ? .checkmark : .none
        case .Passport2:
            let docId = controllerObj?.getDocumentID(docIndex: 2 ,type: .PPT ,category: .Identity_Document)
            self.lblEnrollment.text = enrollment.rawValue+"(#"+(docId ?? "")+")"
            self.accessoryType = (docId != nil) ? .checkmark : .none
        case .NationalID:
            let docId = controllerObj?.getDocumentID(docIndex: 1 ,type: .NATIONAL_ID ,category: .Identity_Document)
            self.lblEnrollment.text = enrollment.rawValue+"(#"+(docId ?? "")+")"
            self.accessoryType = (docId != nil) ? .checkmark : .none
        case .SSN:
            self.lblEnrollment.text = enrollment.rawValue
        case .LiveID, .LiveID_liveness:
            self.lblEnrollment.text = enrollment.rawValue
            self.accessoryType = BlockIDSDK.sharedInstance.isLiveIDRegisterd() ? .checkmark : .none
        case .Pin:
            self.lblEnrollment.text = enrollment.rawValue
            self.accessoryType = BlockIDSDK.sharedInstance.isPinRegistered() ? .checkmark : .none
        default:
            self.lblEnrollment.text = enrollment.rawValue
            self.accessoryType = .none
            break
        }
        
    }

}
