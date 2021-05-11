//
//  AuthenticateViewController.swift
//  BlockIDTestApp
//
//  Created by 1Kosmos Engineering
//  Copyright © 2021 1Kosmos. All rights reserved.
//

import Foundation
import BlockIDSDK

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
    public var qrModel: AuthQRModel!
    var qroptions = ""
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
        scopeAttributesDic = getScopesAttributesDict(scopes: qrModel.scopes ?? "",
                                                                         creds: qrModel.creds ?? "",
                                                                         origin: qrModel.getBidOrigin()!,
                                                                         userId: userId)
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
            qrData = qroptions
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
    
    private func getScopesAttributesDict(scopes: String, creds: String, origin: BIDOrigin, userId: String? = nil) -> [String: Any]? {
        let scopesAttributes = BlockIDSDK.sharedInstance.getScopesAttributesDic(scopes: scopes, creds: creds, origin: origin, userId: userId)
        guard let scopeDictUW = scopesAttributes.scopesAttributesDict else {
            if let  errorUW = scopesAttributes.error, errorUW.code == CustomErrors.kUnauthorizedAccess.code {
                showAppLogin()
            }
            return nil
        }
        return scopeDictUW
    }
    
    private func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnAuthenticate(_ sender: UIButton) {
        guard let data = qrModel else { return }
        let datamodel = AuthRequestModel(lat: location.0, lon: location.1, session: data.session ?? "", creds: data.creds ?? "", scopes: data.scopes ?? "", origin: data.getBidOrigin(), isConsentGiven: true, userId: userId)
        
        switch qrOption {
        case .withScopeData:
            self.authenticateUserWithScopes(datamodel: datamodel)
        case .withPresetData:
            self.authenticateUserWithPreset(datamodel: datamodel)
        default:
            break
        }
        
       
    }
    
    private func authenticateUserWithPreset(datamodel: AuthRequestModel) {
        self.view.makeToastActivity(.center)
        var dictScopes = ["data" : _txtPresetData.text]
        BlockIDSDK.sharedInstance.authenticateUser(sessionId: datamodel.session, creds: datamodel.creds, dictScopes: dictScopes, lat: datamodel.lat, lon: datamodel.lon, origin: datamodel.origin, userId: datamodel.userId) {  [weak self] (status, error) in
            self?.view.hideToastActivity()
            if status {
                //if success
                self?.view.makeToast("You have successfully authenticated to Log In", duration: 3.0, position: .center, title: "Success", completion: {_ in
                    self?.goBack()
                    self?.delegate?.onAuthenticate(status: true)
                    return
                })

            } else {
                if error?.code == NSURLErrorNotConnectedToInternet {
                    self?.view.makeToast(ErrorConfig.noInternet.message, duration: 3.0, position: .center, title: ErrorConfig.noInternet.title, completion: {_ in
                        
                    })
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
   
    
    private func authenticateUserWithScopes(datamodel: AuthRequestModel) {
        self.view.makeToastActivity(.center)

        BlockIDSDK.sharedInstance.authenticateUser(sessionId: datamodel.session, creds: datamodel.creds, scopes: datamodel.scopes, lat: datamodel.lat, lon: datamodel.lon, origin: datamodel.origin, userId: datamodel.userId) {  [weak self] (status, error) in
            self?.view.hideToastActivity()
            if status {
                //if success
                self?.view.makeToast("You have successfully authenticated to Log In", duration: 3.0, position: .center, title: "Success", completion: {_ in
                    self?.goBack()
                    self?.delegate?.onAuthenticate(status: true)
                    return
                })

            } else {
                if error?.code == NSURLErrorNotConnectedToInternet {
                    self?.view.makeToast(ErrorConfig.noInternet.message, duration: 3.0, position: .center, title: ErrorConfig.noInternet.title, completion: {_ in
                        
                    })
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
