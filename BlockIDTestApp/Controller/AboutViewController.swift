//
//  AboutViewController.swift
//  BlockIDTestApp
//
//  Created by Aditya Sharma on 15/11/22.
//

import UIKit
import BlockID

// MARK: - Enums -
enum InfoType: String, CaseIterable {
    case rootTenant = "Root Tenant: "
    case appTenant = "App Tenant: "
    case licenseKey = "License Key: "
    case did = "DID: "
    case publicKey = "Public Key: "
    case sdkVersion = "SDK Version: "
    case appVersion = "APP Version: "
}

class AboutViewController: UIViewController {
    
    // MARK: - IBOutlets -
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Private Properties -
    private var tablewViewCellId = "AboutTableviewCell"
    private var copiedTxt: String = ""
    // MARK: - View Life cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    // MARK: - IBActions -
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func doCopy(_ sender: Any) {
        let pasteboard = UIPasteboard.general
        pasteboard.string = getPasteBoardString()
    }
    
    // MARK: - Private methods -
    // get copied text...
    private func getPasteBoardString() -> String {
        
        var copiedTxt = ""
        InfoType.allCases.forEach {
            switch $0 {
            case .rootTenant:
                copiedTxt += $0.rawValue
                if let tenant = BlockIDSDK.sharedInstance.getTenant() {
                    let dns = "DNS: " + (tenant.dns ?? "-")
                    let tag = "Tag: " + (tenant.tenantTag ?? "-") + " (" + "\(tenant.tenantId ?? "-")" + ")"
                    let community = "Community: " + (tenant.community ?? "-") + " (" + "\(tenant.communityId ?? "-")" + ")"
                    let subTitle = "\n" + dns + "\n" + tag + "\n" + community + "\n\n"
                    copiedTxt += subTitle
                }
            case .appTenant:
                copiedTxt += $0.rawValue
                if let tenant = BlockIDSDK.sharedInstance.getAppTenant() {
                    let dns = "DNS: " + (tenant.dns ?? "-")
                    let tag = "Tag: " + (tenant.tenantTag ?? "-") + " (" + "\(tenant.tenantId ?? "-")" + ")"
                    let community = "Community: " + (tenant.community ?? "-") + " (" + "\(tenant.communityId ?? "-")" + ")"
                    let subTitle = "\n" + dns + "\n" + tag + "\n" + community + "\n\n"
                    copiedTxt += subTitle
                }
            case .licenseKey:
                let licenseKey = Tenant.licenseKey.prefix(8) + "-xxxx-xxxx-xxxx-xxxxxxxx" + Tenant.licenseKey.suffix(4)
                copiedTxt += $0.rawValue +  licenseKey + "\n\n"
            case .did:
                copiedTxt += $0.rawValue + BlockIDSDK.sharedInstance.getDID() + "\n\n"
            case .publicKey:
                copiedTxt += $0.rawValue + BlockIDSDK.sharedInstance.getWalletPublicKey() + "\n\n"
            case .sdkVersion:
                copiedTxt += $0.rawValue + (fetchSDKVersion() ?? "") + "\n\n"
            case .appVersion:
                let version = CommonFunctions.getAppBundleVersion().0 + " \( "(" + CommonFunctions.getAppBundleVersion().1 + ")"  )"
                copiedTxt += $0.rawValue + ": " + version
            }
        }
        return copiedTxt
    }
    
    // Fetch SDK/App Version...
    private func fetchSDKVersion() -> String? {
        if let version = BlockIDSDK.sharedInstance.getVersion() {
            if let buildNo = version.components(separatedBy: ".").max(by: {$1.count > $0.count}) {
                let versionArr = version.components(separatedBy: ".")
                var sdkVersion = ""
                for index in 0...versionArr.count - 1 {
                    if versionArr[index] != buildNo {
                        if index < versionArr.count - 2 {
                            sdkVersion += versionArr[index] + "."
                        } else {
                            sdkVersion += versionArr[index]
                        }
                    }
                }
                
                return sdkVersion + " \( "(" + buildNo + ")"  )"
            }
        }
        return nil
    }
}

// MARK: - Extension UITableViewDataSource -
extension AboutViewController: UITableViewDataSource {
 
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return InfoType.allCases.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier:
                                                    tablewViewCellId,
                                                 for: indexPath)
        
        cell.textLabel?.text = InfoType.allCases[indexPath.row].rawValue
        switch InfoType.allCases[indexPath.row] {
            
        case .rootTenant:
            if let tenant = BlockIDSDK.sharedInstance.getTenant() {
                let dns = "DNS: " + (tenant.dns ?? "-") + "\n"
                let tag = "Tag: " + (tenant.tenantTag ?? "-") + " (" + "\(tenant.tenantId ?? "-")" + ")" + "\n"
                let community = "Community: " + (tenant.community ?? "-") + " (" + "\(tenant.communityId ?? "-")" + ")" + "\n"
                let subTitle = dns + tag + community
                cell.detailTextLabel?.text = subTitle
            }
        case .appTenant:
            if let tenant = BlockIDSDK.sharedInstance.getAppTenant() {
                let dns = "DNS: " + (tenant.dns ?? "-") + "\n"
                let tag = "Tag: " + (tenant.tenantTag ?? "-") + " (" + "\(tenant.tenantId ?? "-")" + ")" + "\n"
                let community = "Community: " + (tenant.community ?? "-")  + " (" + "\(tenant.communityId ?? "-")" + ")" + "\n"
                let subTitle = dns + tag + community
                cell.detailTextLabel?.text = subTitle
            }
        case .licenseKey:
           let licenseKey = Tenant.licenseKey.prefix(8) + "-xxxx-xxxx-xxxx-xxxxxxxx" + Tenant.licenseKey.suffix(4)
            cell.detailTextLabel?.text = String(licenseKey)
        case .did:
            cell.detailTextLabel?.text = BlockIDSDK.sharedInstance.getDID()
        case .publicKey:
            cell.detailTextLabel?.text = BlockIDSDK.sharedInstance.getWalletPublicKey()
        case .sdkVersion:
            cell.detailTextLabel?.text = fetchSDKVersion() ?? "-"
        case .appVersion:
            let version = CommonFunctions.getAppBundleVersion().0 + " \( "(" + CommonFunctions.getAppBundleVersion().1 + ")"  )"
            cell.detailTextLabel?.text = version
        }
        return cell
    }
}

// MARK: - Extension UITableViewDelegate -
extension AboutViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}
