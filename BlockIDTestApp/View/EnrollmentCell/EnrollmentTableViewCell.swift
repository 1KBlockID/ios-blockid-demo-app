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
        
        self.detailTextLabel?.text = ""
        switch enrollment {
        case .AddUser:
            self.textLabel?.text = enrollment.rawValue
            if let linkedUserAccounts = BlockIDSDK.sharedInstance.getLinkedUserAccounts().linkedUsers, linkedUserAccounts.count > 0 {
                
                if let tagNCommunity = (linkedUserAccounts[0].origin.name != nil && !(linkedUserAccounts[0].origin.name?.isEmpty ?? false)) ?
                linkedUserAccounts[0].origin.name :
                        linkedUserAccounts[0].origin.community {
                    if let tag = linkedUserAccounts[0].origin.tag {
                        let tenatInfo = tag + " | " + tagNCommunity
                        self.textLabel?.text = linkedUserAccounts[0].userId 
                        self.detailTextLabel?.text = tenatInfo
                    }

                } else {
                    self.textLabel?.text = linkedUserAccounts[0].userId
                }
                self.accessoryType = .checkmark
            } else {
                self.accessoryType = .none
            }
        case .DeviceAuth:
            self.textLabel?.text = enrollment.rawValue
            self.accessoryType = BlockIDSDK.sharedInstance.isDeviceAuthRegisterd() ? .checkmark : .none
        case .DriverLicense:
            let docId = controllerObj?.getDocumentID(docIndex: 1 ,type: .DL ,category: .Identity_Document)
            self.textLabel?.text = enrollment.rawValue+"(#"+(docId ?? "")+")"
            self.accessoryType = (docId != nil) ? .checkmark : .none
        case .Passport1:
            let docId = controllerObj?.getDocumentID(docIndex: 1 ,type: .PPT ,category: .Identity_Document)
            self.textLabel?.text = enrollment.rawValue+"(#"+(docId ?? "")+")"
            self.accessoryType = (docId != nil) ? .checkmark : .none
        case .Passport2:
            let docId = controllerObj?.getDocumentID(docIndex: 2 ,type: .PPT ,category: .Identity_Document)
            self.textLabel?.text = enrollment.rawValue+"(#"+(docId ?? "")+")"
            self.accessoryType = (docId != nil) ? .checkmark : .none
        case .NationalID:
            let docId = controllerObj?.getDocumentID(docIndex: 1 ,type: .NATIONAL_ID ,category: .Identity_Document)
            self.textLabel?.text = enrollment.rawValue+"(#"+(docId ?? "")+")"
            self.accessoryType = (docId != nil) ? .checkmark : .none
        case .SSN:
            self.textLabel?.text = enrollment.rawValue
        case .LiveID, .LiveID_liveness:
            self.textLabel?.text = enrollment.rawValue
            self.accessoryType = BlockIDSDK.sharedInstance.isLiveIDRegisterd() ? .checkmark : .none
        case .Pin:
            self.textLabel?.text = enrollment.rawValue
            self.accessoryType = BlockIDSDK.sharedInstance.isPinRegistered() ? .checkmark : .none
        default:
            self.textLabel?.text = enrollment.rawValue
            self.accessoryType = .none
            break
        }
        
    }

}
