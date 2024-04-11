//
//  AuthenticateViewController.swift
//  BlockIDTestApp
//
//  Created by 1Kosmos Engineering
//  Copyright © 2021 1Kosmos. All rights reserved.
//

import Foundation
import BlockID

protocol AuthenticateViewControllerDelegate {
    func onAuthenticate(status: Bool)
    func unauthorisedUser()
}
struct UserConsentInfoTVCDataSetup {
    let scopeName: String?
    let scopeValue: String?
}
class AuthenticateViewController: UIViewController {

    public var delegate : AuthenticateViewControllerDelegate?
    public var qrOption : QROptions?
    public var qrModel: AuthenticationPayloadV1!
    var qrOptions = ""
    var location: (Double, Double) = (0.0, 0.0)
    var userId: String?
    private var scopeAttributesDic: [String: Any]?
    private var scopesSequence = ["name","userid","ppt","dl","creds","scep_creds","nationalid","did"]
    var displayScopeArr = [UserConsentInfoTVCDataSetup]()
    var ConsentScreenCellIdentifier = "ConsentScreenCell"
    
    private var scopesDisplayNameDic = [
                                        "did":"DID :",
                                        "Name":"Name",
                                        "userid":"User ID :",
                                       
                                        "ppt":"Passport #:",
                                        "dl":"Drivers License # :",
                                        "creds":"Creds :",
                                        "scep_creds":"SCEP :",
                                        "nationalid":"National ID # :"
                                        ]
    
    @IBOutlet weak var _txtPresetData: UITextField!
    @IBOutlet weak var _tblScope: UITableView!
   
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        _txtPresetData.delegate = self
        self.view.makeToastActivity(.center)
        self.view.isUserInteractionEnabled = false
        getScopesAttributesDict(scopes: qrModel.scopes ?? "",
                                creds: qrModel.creds ?? "",
                                origin: qrModel.getBidOrigin()!,
                                userId: userId) { scopeDict in
            
            DispatchQueue.main.async {
                self.view.hideToastActivity()
                self.view.isUserInteractionEnabled = true
            }
            self.scopeAttributesDic = scopeDict
            
        }
        self.userId = scopeAttributesDic?["userid"] as? String
        let clientName = (qrModel?.name != nil && qrModel?.name != "") ? qrModel.name : qrModel?.tag

        _tblScope.register(UINib(nibName: "ConsentScreenCell", bundle: nil), forCellReuseIdentifier: "ConsentScreenCell")
        switch qrOption {
        case .withScopeData:
            createScopesDataListToDisplay()
            _txtPresetData.isHidden = true
            _tblScope.isHidden = false
            
        case .withPresetData:
            _txtPresetData.isHidden = false
            _tblScope.isHidden = true
        case .none:
            break
        }
    }
    
    @IBAction func onAuthenticate(_ sender: UIButton) {
        var qrData = ""
        switch qrOption {
        case .withScopeData:
            qrData = qrOptions
        case .withPresetData:
            qrData = _txtPresetData.text ?? ""
        case .none:
            break
        }
    }
    
    private func createScopesDataListToDisplay() {

        for scopeItem in scopesSequence {
            var label = scopesDisplayNameDic[scopeItem]
            var value = ""
            if scopeItem == "name"  {
                label = "Name :"
                if let firstName = self.scopeAttributesDic?["firstname"]  as? String {
                    value = firstName
                }
                if let lastName = self.scopeAttributesDic?["lastname"]  as? String {
                    value = (value != "" ? value + " " + lastName : lastName)
                }
            }
            else {
                if let scopeValue = self.scopeAttributesDic?[scopeItem]  as? String {
                    value = scopeValue
                }
            }
            if value != "" {
                let item = UserConsentInfoTVCDataSetup(scopeName: label, scopeValue: value as? String)
                displayScopeArr.append(item)
            }
        }
        _tblScope.reloadData()
    }
    
    private func getScopesAttributesDict(scopes: String, creds: String, origin: BIDOrigin, userId: String? = nil, completion: @escaping ([String: Any]?) -> Void) {
        
        BlockIDSDK.sharedInstance.getScopesAttributesDic(scopes: scopes,
                                                         creds: creds,
                                                         origin: origin,
                                                         userId: userId) { scopesAttributesDict, error in
            if let scopeDictionary = scopesAttributesDict {
                if let  errorUW = error, errorUW.code == CustomErrors.kUnauthorizedAccess.code {
                    self.showAppLogin()
                    completion(nil)
                } else {
                    completion(scopeDictionary)
                }
            } else {
                completion(nil)
            }
        }
    }
    
    private func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnAuthenticate(_ sender: UIButton) {
        guard let data = qrModel else { return }
        
        // check authType for authentication..
        if let authType = data.authtype?.lowercased() {
            switch authType {
            case "face":
                askForLiveID(data: data)
            case "pin":
                askForPin(data: data)
            case "fingerprint":
                askForDeviceAuth(data: data)
            default:
                doAuthenticate(data: data)
            }
        }
    }
    
    private func askForLiveID(data: AuthenticationPayloadV1) {
        
        if !BlockIDSDK.sharedInstance.isLiveIDRegisterd() {
            self.view.makeToast("Please enroll LiveID in order to authenticate.", duration: 3.0, position: .center, title: "Error", completion: {_ in
                self.goBack()
            })
            return
        }
        
        // Authenticate liveID on liveIDcontroller screen...
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        if let liveIDVC = storyBoard.instantiateViewController(withIdentifier: "LiveIDViewController") as? LiveIDViewController {
            liveIDVC.isForVerification = true
            liveIDVC.onFinishCallback = { (status) -> Void in
                if status {
                    self.doAuthenticate(data: data)
                }
            }
            self.navigationController?.pushViewController(liveIDVC, animated: true)
        }
    }
    
    private func askForPin(data: AuthenticationPayloadV1) {
        
        if !BlockIDSDK.sharedInstance.isPinRegistered() {
            self.view.makeToast("Please enroll PIN in order to authenticate.", duration: 3.0, position: .center, title: "Error", completion: {_ in
                self.goBack()
            })
            return
        }
        
        // Authenticate PIN on PinViewcontroller screen...
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        if let pinVC = storyBoard.instantiateViewController(withIdentifier: "PinViewController") as? PinViewController {
            pinVC.pinActivity = .isLogin
            pinVC.onFinishCallback = { (status) -> Void in
                if status {
                    self.doAuthenticate(data: data)
                }
            }
            self.navigationController?.pushViewController(pinVC, animated: true)
        }
        
    }
    
    private func askForDeviceAuth(data: AuthenticationPayloadV1) {
        
        if !BlockIDSDK.sharedInstance.isDeviceAuthRegisterd() {
            self.view.makeToast("Please enroll Touch ID / Face ID in order to authenticate.", duration: 3.0, position: .center, title: "Error", completion: {_ in
                self.goBack()
            })
            return
        }
        
        // Authenticate DeviceAuth...
        BIDAuthProvider.shared.verifyDeviceAuth { (success, error, message) in
            if !success {
                if let messageUW = message {
                    self.showAlertView(title: "Error", message: messageUW)
                }
            } else {
                self.doAuthenticate(data: data)
            }
        }
    }
    
    private func doAuthenticate(data: AuthenticationPayloadV1) {
        var dataModel: AuthRequestModel
        
        if let sessionUrl = data.sessionUrl, !sessionUrl.isEmpty {
            dataModel = AuthRequestModel(lat: location.0, lon: location.1, session: data.session ?? "", creds: data.creds ?? "", scopes: data.scopes ?? "", origin: data.getBidOrigin(), isConsentGiven: true, userId: userId, sessionUrl: sessionUrl)
        } else {
            dataModel = AuthRequestModel(lat: location.0, lon: location.1, session: data.session ?? "", creds: data.creds ?? "", scopes: data.scopes ?? "", origin: data.getBidOrigin(), isConsentGiven: true, userId: userId)
        }
        
        switch qrOption {
        case .withScopeData:
            self.authenticateUserWithScopes(dataModel: dataModel)
        case .withPresetData:
            self.authenticateUserWithPreset(dataModel: dataModel)
        default:
            break
        }
    }
    
    private func authenticateUserWithPreset(dataModel: AuthRequestModel) {
        self.view.makeToastActivity(.center)
        let dictScopes = ["data" : _txtPresetData.text]
            
        BlockIDSDK.sharedInstance.authenticateUser(sessionId: dataModel.session, sessionURL: dataModel.sessionUrl, creds: dataModel.creds, dictScopes: dictScopes, lat: dataModel.lat, lon: dataModel.lon, origin: dataModel.origin, userId: dataModel.userId) {  [weak self] (status, sessionid, error) in
            self?.view.hideToastActivity()
            if status {
                //if success
                self?.view.makeToast("You have successfully authenticated to Log In", duration: 3.0, position: .center, title: "Success", completion: {_ in
                    self?.goBack()
                    self?.delegate?.onAuthenticate(status: true)
                    return
                })

            } else {
                if error?.code == NSURLErrorNotConnectedToInternet || error?.code == CustomErrors.Network.OFFLINE.code {
                    let localizedMessage = "OFFLINE".localizedMessage(CustomErrors.Network.OFFLINE.code)
                    self?.view.makeToast(localizedMessage,
                                         duration: 3.0,
                                         position: .center,
                                         title: ErrorConfig.noInternet.title, completion: {_ in })
                } else if (error)?.code == CustomErrors.kUnauthorizedAccess.code {
                    self?.view.makeToast(error!.message, duration: 3.0, position: .center, title: "", completion: {_ in
                        self?.goBack()
                        self?.delegate?.unauthorisedUser()
                    })
                } else {
                    self?.view.makeToast(error!.message, duration: 3.0, position: .center, title: "", completion: {_ in
                        self?.goBack()
                        self?.delegate?.onAuthenticate(status: false)
                    })
                }
            }
        }
    }
   
    
    private func authenticateUserWithScopes(dataModel: AuthRequestModel) {
        self.view.makeToastActivity(.center)

        BlockIDSDK.sharedInstance.authenticateUser(sessionId: dataModel.session, sessionURL: dataModel.sessionUrl, creds: dataModel.creds, scopes: dataModel.scopes, lat: dataModel.lat, lon: dataModel.lon, origin: dataModel.origin, userId: dataModel.userId) {  [weak self] (status, sessionid, error) in
            self?.view.hideToastActivity()
            if status {
                //if success
                self?.view.makeToast("You have successfully authenticated to Log In", duration: 3.0, position: .center, title: "Success", completion: {_ in
                    self?.goBack()
                    self?.delegate?.onAuthenticate(status: true)
                    return
                })

            } else {
                if error?.code == NSURLErrorNotConnectedToInternet ||
                    error?.code == CustomErrors.Network.OFFLINE.code {
                    let localizedMessage = "OFFLINE".localizedMessage(CustomErrors.Network.OFFLINE.code)
                    self?.view.makeToast(localizedMessage,
                                         duration: 3.0,
                                         position: .center,
                                         title: ErrorConfig.noInternet.title, completion: {_ in })
                } else if (error)?.code == CustomErrors.kUnauthorizedAccess.code {
                    self?.view.makeToast(error!.message, duration: 3.0, position: .center, title: "", completion: {_ in
                        self?.goBack()
                        self?.delegate?.unauthorisedUser()
                    })
                } else {
                    self?.view.makeToast(error!.message, duration: 3.0, position: .center, title: "", completion: {_ in
                        self?.goBack()
                        self?.delegate?.onAuthenticate(status: false)
                    })
                }
            }
        }
    }
}
extension AuthenticateViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayScopeArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ConsentScreenCellIdentifier, for: indexPath) as! ConsentScreenCell
        cell.setupCell(dataSetup: displayScopeArr[indexPath.row])
        return cell
    }
    
    
}

extension AuthenticateViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
