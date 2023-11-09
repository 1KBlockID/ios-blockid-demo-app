//
//  AppDelegate.swift
//  BlockIDTestApp
//
//  Created by 1Kosmos Engineering
//  Copyright © 2021 1Kosmos. All rights reserved.
//

import UIKit
import Firebase
import WalletConnectSign
import BlockID

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var currentProposal: Session.Proposal?
    var walletConnectHelper: WalletConnectHelper?
    var sessionItems: [ActiveSessionItem] = []

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Confire firebase for Crashalytics
        FirebaseApp.configure()
        return true
    }
    
   /* class func sharedAppDelegate() -> AppDelegate? {
        return UIApplication.shared.delegate as? AppDelegate
    }
    
    var orientationLock = UIInterfaceOrientationMask.portrait
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return self.orientationLock
    }*/
}

// MARK: -
extension UIApplication {
    func topMostViewController() -> UIViewController? {
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        if var topController = keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController.topMostViewController()
        }
        return nil
    }
}
