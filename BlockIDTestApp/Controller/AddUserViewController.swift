//
//  AddUserViewController.swift
//  BlockIDTestApp
//
//  Created by Aditya Sharma on 10/05/22.
//

import UIKit
import BlockIDSDK
import WebKit
import AVKit
import CoreLocation

class AddUserViewController: UIViewController {

    // MARK: - IBOutlets -
    @IBOutlet private weak var webView: WKWebView!
    @IBOutlet weak var viewQRScan: BIDScannerView!
    @IBOutlet weak var imgQRscan: UIImageView!
    
    // MARK: - Private Properties -
    private var userOnboardingServerPublicKey: String?
    private let selectedMode: ScanningMode = .SCAN_LIVE
    private var qrScannerHelper: QRScannerHelper?
    private var magicLinkData: MagicLinkModel?
    private var magicLink: MagicLink?
    typealias CompletionBlockCoreLocation = () -> Void
    var completionForLocationObj: CompletionBlockCoreLocation?
    var location: (Double, Double) = (0.0, 0.0)
    
    var locationManager = CLLocationManager()
    
    // MARK: - View Life cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        scanQRCode()
        webView.navigationDelegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.locationManager.requestAlwaysAuthorization()
    }
    
    // MARK: - IBActions -
    @IBAction func onBack(_ sender: Any) {
        self.goBack()
    }
    
    // MARK: - Private methods -
    // INIT QR scanner
    private func scanQRCode() {
        qrScannerHelper = QRScannerHelper.init(scanningMode: selectedMode,
                                               bidScannerView: viewQRScan,
                                               kQRScanResponseDelegate: self)
        qrScannerHelper?.startQRScanning()
    }

    // Validate ACR code API..
    private func  validateAccessCode() {
        self.view.makeToastActivity(.center)
        guard let origin = magicLinkData?.getBidOrigin() else {
            DispatchQueue.main.async {
                self.view.hideToastActivity()
            }
            self.view.makeToast("Unsupported QR code detected.",
                                duration: 3.0,
                                position: .center,
                                title: "Invalid Code",
                                completion: {_ in
                self.goBack()
            })
            return
        }
        
        BlockIDSDK.sharedInstance.validateAccessCode(code: magicLinkData?.code ?? "", origin: origin) { (status, error, response) in
            self.view.hideToastActivity()
            if status {
                // success
                var authType = response?.accesscodepayload.authType ?? ""
                if authType.isEmpty {
                    authType = MagicLinkAuthType.none.rawValue
                }
                
                if let response = response {
                        self.handleACRFlow(authType: authType,
                                           origin: origin,
                                           userId: response.accesscodepayload.userid,
                                           accessCodePayload: response.accesscodepayload)
                    }
            } else {
                // failure
                self.view.makeToast(error?.message ?? "User onboarding failed", duration: 3.0, position: .center, title: "Error", completion: {_ in
                    self.goBack()
                })
            }
        }
    }
    
    // Handle back navigation..
    private func goBack() {
        self.navigationController?.popViewController(animated: true)
    }

    func performMagicLinkOperation(completion: @escaping CompletionBlockCoreLocation) {
        completionForLocationObj = completion
    }
    
    // Handle ACR flow w.r.t MagicLink Auth type  ..
    private func handleACRFlow(authType: String, origin: BIDOrigin, userId: String, accessCodePayload: AccessCodeResponseDataPayload, phoneNumber: String? = nil) {
        
        switch authType {
        case MagicLinkAuthType.none.rawValue:
            self.getUserOnboardingPublicKey()
        case MagicLinkAuthType.otp.rawValue, MagicLinkAuthType.authn.rawValue:
            self.view.makeToast("Auth type: \(authType) not supported.",
                                duration: 3.0,
                                position: .center,
                                title: "Error",
                                completion: {_ in
                self.goBack()
            })
        default:
            break
        }
    }
    
    // Process QRCode data ..
    private func processQRData(_ data: String) {
        if data.hasPrefix("https://") && data.contains("/acr") {
            if let incomingURL = URL(string: data) {
                // validate magic link data
                    guard let components = NSURLComponents(url: incomingURL,
                                                           resolvingAgainstBaseURL: true),
                          let scheme = components.scheme,
                          let host = components.host else {
                        return
                    }
                    // Check for specific URL components that you need.
                    guard let params = components.queryItems else {
                        return
                    }
                    if let code = params.first(where: { $0.name == "code" })?.value {
                        self.magicLink = MagicLink(url: incomingURL.absoluteString,
                                                  baseUrl: scheme + "://" + host,
                                                  code: code,
                                                  path: incomingURL.path)
                        
                    } else {
                        
                        self.view.makeToast("Your device linking was unsuccessful. Please restart the registration.", duration: 3.0,
                                            position: .center,
                                            title: "Error",
                                            completion: {_ in
                            self.goBack()
                        })
                    }
            }
            
            //decode the base64 payload data
            guard let code = magicLink?.code, let decodedData = Data(base64Encoded: code) else {
                self.view.makeToast("Your device linking was unsuccessful. Please restart the registration.",
                                    duration: 3.0,
                                    position: .center,
                                    title: "Error",
                                    completion: {_ in
                    self.goBack()
                })
                return
            }
            
            if let decodedString = String(data: decodedData,
                                          encoding: .utf8) {
                    magicLinkData = CommonFunctions.jsonStringToObject(json: decodedString) as MagicLinkModel?
            }
            
            validateAccessCode()
        }
    }
    
    // Check if location services are enabled ......
    private func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
                case .notDetermined, .restricted, .denied:
                self.buildInAppBrowserURL()
                self.completionForLocationObj = nil
                case .authorizedAlways, .authorizedWhenInUse:
                self.locationManager.startUpdatingLocation()
                self.performMagicLinkOperation {
                    self.buildInAppBrowserURL()
                    self.completionForLocationObj = nil
                }
                @unknown default:
                    break
            }
        } else {
            self.buildInAppBrowserURL()
            self.completionForLocationObj = nil
        }
    }
    
    // Fetch userOnboarding public key ...
    private func getUserOnboardingPublicKey() {
        
        let baseUrl = (magicLink?.baseUrl ?? "") + (magicLink?.path ?? "")
        let url = baseUrl + "/publickeys"
        let headers = ["Content-Type": "application/json"]
        BIDNetworkManager.sharedInstance.makeRequest(requestMethod: .get,
                                                     serviceUrl: url,
                                                     requestBody: nil,
                                                     requestHeaders: headers) { (response: NetworkResponseCallback<ServerPublicKeyResponse>) in
            // success
            if response.statusCode == 200 && response.error == nil {
                self.userOnboardingServerPublicKey = response.result?.publicKey
                self.checkLocationServices()
                return
            }
            // failure
            let error = ErrorResponse(code: response.statusCode ?? 001, msg: response.error?.localizedDescription ?? "")
            if error.code == NSURLErrorNotConnectedToInternet || error.code == CustomErrors.Network.OFFLINE.code {
                let localizedMessage = "OFFLINE".localizedMessage(CustomErrors.Network.OFFLINE.code)
                self.showAlertView(title: ErrorConfig.noInternet.title,
                                   message: localizedMessage)
            } else {
                self.view.makeToast(error.message,
                                    duration: 3.0,
                                    position: .center,
                                    title: "Error",
                                    completion: {_ in
                    self.goBack()
                })
            }
        }
    }
}

// MARK: - Extension QRScanResponseDelegate -
extension AddUserViewController: QRScanResponseDelegate {
    func onQRScanResult(qrCodeData: String?) {
        if qrCodeData == nil {

            AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
                if !response {
                    DispatchQueue.main.async {
                        self.alertForCameraAccess()
                    }
                }
            }
            return
        }
        qrScannerHelper?.stopQRScanning()
        viewQRScan.isHidden = true
        imgQRscan.isHidden = true
        self.processQRData(qrCodeData ?? "")
    }
}

extension AddUserViewController {
    
    private func buildInAppBrowserURL() {
        var finalURL = magicLink?.url ?? ""
        if let payload = makePayload(userOnboardingServerPublicKey ?? "",
                                     code: self.magicLinkData?.code ?? "") {
            finalURL += "&payload=" + payload
            debugPrint("Magic Link url with code + payload -> \(finalURL)")
            if let url = URL(string: finalURL) {
                webView.load(URLRequest(url: url))
            }
        }
    }
    
    private func makePayload(_ publicKey: String, code: String) -> String? {
        let eventDataRequest = BlockIDSDK.sharedInstance.getEventData(publicKey: publicKey,
                                                                      lon: location.1, lat: location.0)
        guard let eventDataRequest = BlockIDSDK.sharedInstance.encryptString(str: eventDataRequest, rcptKey: publicKey) else {
            return nil
        }
        let urlData = MagicLinkPayload(did: BlockIDSDK.sharedInstance.getDID(),
                                       eventData: eventDataRequest,
                                       sender: AccountAuthConstants.kAuthSender,
                                       code: code,
                                       os: "ios",
                                       ial: "")
        
        return RequestUrlPayload(data: urlData, publicKey: publicKey).base64Payload()
    }
    
    private func onUserAuthResponseReceived(_ payload: String) {
        webView.isHidden = true
        self.view.makeToastActivity(.center)
        
        guard let decodedData = Data(base64Encoded: payload) else {
            self.view.makeToast("User registration is unsuccessful. Please try again.",
                                duration: 3.0, position: .center,
                                title: "Error", completion: {_ in
                self.goBack()
            })
            return
        }
        guard let decodedString = String(data: decodedData, encoding: .utf8),
              let publicKey = userOnboardingServerPublicKey else {
            return
        }
        
        let responseStr = BlockIDSDK.sharedInstance.decryptString(str: decodedString,
                                                                  senderKey: publicKey)
        guard let responseStr = responseStr,
                let response = CommonFunctions.jsonStringToObject(json: responseStr) as AuthLinkUrlData? else {
            return
        }
        
        if let responseData = response.data {
            let linkResponseStr = BlockIDSDK.sharedInstance.decryptString(str: responseData,
                                                                          senderKey: (response.getPublicKey()))
            guard let linkResponseStr = linkResponseStr,
                  let linkResponse = CommonFunctions.jsonStringToObject(json: linkResponseStr) as BIDOnboardedUserAccount? else {
                return
            }
            
            addUser(linkResponse)
        }
    }
    
    //  addPrelink user API call...
    private func addUser(_ user: BIDOnboardedUserAccount?) {
        self.view.hideToastActivity()
        
        guard let userIdUW = user?.userId,
                let originUW = user?.origin,
                let isLinkedUW = user?.isLinked,
                isLinkedUW == true else {
            self.view.makeToast(ErrorConfig.error.message,
                                duration: 3.0,
                                position: .center,
                                title: ErrorConfig.error.title,
                                completion: {_ in
                self.goBack()
            })
            return
        }
        
        BlockIDSDK.sharedInstance.addPreLinkedUser(userId: userIdUW,
                                                   scep_hash: user?.scep_hash ?? "",
                                                   scep_privatekey: user?.scep_privatekey ?? "",
                                                   origin: originUW, account: user?.account) { (status, error) in
            if status {
                self.view.makeToast("User registration successful.",
                                    duration: 3.0,
                                    position: .center,
                                    title: "Success",
                                    completion: {_ in
                    self.goBack()
                })
            } else {
                self.view.makeToast("User registration is unsuccessful. Please try again.",
                                    duration: 3.0,
                                    position: .center,
                                    title: "Error",
                                    completion: {_ in
                    self.goBack()
                })
            }
        }
    }
}

// MARK: - WKNavigationDelegate
extension AddUserViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        self.view.makeToastActivity(.center)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.view.hideToastActivity()
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let urlStr = navigationAction.request.url?.absoluteString {
            if !urlStr.hasPrefix(AccountAuthConstants.kAuthSender) {
                decisionHandler(.allow)
                return
            }
            
            if let url = navigationAction.request.url, let urlComponent = URLComponents(string: url.absoluteString) {
                let payload = urlComponent.queryItems?.first(where: { $0.name == "payload" })?.value ?? ""
                onUserAuthResponseReceived(payload)
            }
            
        }
        decisionHandler(.cancel)
    }
}

// MARK: - CLLocationManagerDelegate
extension AddUserViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue: CLLocationCoordinate2D = manager.location!.coordinate
        location = ( locValue.latitude, locValue.longitude)
        locationManager.stopUpdatingLocation()
        guard let completion = completionForLocationObj else {
            return
        }
        completion()
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.denied {
            // The user denied authorization
            guard let completion = completionForLocationObj else {
                return
            }
            completion()
        }
    }
}
