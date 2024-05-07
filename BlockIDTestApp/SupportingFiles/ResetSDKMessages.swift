//
//  ResetSDKMessages.swift
//  ios-kernel
//
//  Created by Prasanna Gupta on 26/04/24.
//  Copyright © 2024 1Kosmos. All rights reserved.
//

import Foundation

enum ResetSDK: String {
     case resetAppOptionClicked = "Reset App option click from Home Screen",
          freshInstallAndBuildVersionNotFound = "Fresh installation and build version not found in userdefaults"
    
    func message() -> String {
        return self.rawValue
    }
}
