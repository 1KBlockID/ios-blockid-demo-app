//
//  AboutViewController.swift
//  BlockIDTestApp
//
//  Created by Aditya Sharma on 15/11/22.
//

import UIKit
import BlockID
import AuthenticationServices


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

class AboutViewController: UIViewController, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    
    // MARK: - ASAuthorizationControllerDelegate
       func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
           if let credential = authorization.credential as? ASAuthorizationPlatformPublicKeyCredentialRegistration {
               print("Registration succeeded")
               print("Attestation object: \(credential.rawAttestationObject?.base64EncodedString() ?? "nil")")
               print("ClientDataJSON: \(credential.rawClientDataJSON.base64EncodedString())")
           } else if let credential = authorization.credential as? ASAuthorizationPlatformPublicKeyCredentialAssertion {
               print("Sign-in succeeded")
               print("AuthenticatorData: \(credential.rawAuthenticatorData.base64EncodedString())")
               print("ClientDataJSON: \(credential.rawClientDataJSON.base64EncodedString())")
               print("Signature: \(credential.signature.base64EncodedString())")
               print("UserID: \(String(data: credential.userID, encoding: .utf8) ?? "nil")")
           }
       }
       
       func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
           print("❌ Authorization failed: \(error.localizedDescription)")
       }
    
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
    
    @IBAction func doRegister(_ sender: Any) {
        self.registerPasskey()
    }
    
    @IBAction func doAuthenticate(_ sender: Any) {
        self.signInWithPasskey(challengeBase64Url: "I4kZ2uIhowLR6W0dLTDVhP3ZBdiHsMBvd_hStZXmLOM")
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
    
    func registerPasskey() {
        let challengeData = Data("srE92KlDQKJzycDpJsd3y2EIEtYGXlkClmup0mTcJEw".utf8)
        let userID = Data("rnjSNw2n-txpJGqVBu5XXoGtazag4yWt7odPFx41LHo".utf8)

        let provider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: "1k-dev.1kosmos.net")
        let request = provider.createCredentialRegistrationRequest(challenge: challengeData, name: "pankti", userID: userID)

//        request.userName = "pankti"
        request.displayName = "panktimistry"

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    
    func signInWithPasskey(challengeBase64Url: String) {
        // Convert challenge (base64url string) into Data
        guard let challengeData = Data(base64URLEncoded: challengeBase64Url) else {
            print("Invalid challenge")
            return
        }

        // 1. Create the provider with your relying party ID (domain)
        let provider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: "1k-dev.1kosmos.net")

        // 2. Create assertion request with the server challenge
        let request = provider.createCredentialAssertionRequest(challenge: challengeData)

        // 3. Ask system to perform the sign-in
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
}

// MARK: - Extension UITableViewDelegate -
extension AboutViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

extension Data {
    init?(base64URLEncoded base64url: String) {
        var base64 = base64url
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        let padding = base64.count % 4
        if padding > 0 {
            base64.append(String(repeating: "=", count: 4 - padding))
        }
        self.init(base64Encoded: base64)
    }
}

