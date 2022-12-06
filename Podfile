# Uncomment the next line to define a global platform for your project
 platform :ios, '13.0'

target 'BlockIDTestApp' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for BlockIDTestApp
  pod 'Toast-Swift', '~> 5.0.1'
  pod 'TrustWalletCore', '~> 2.5.6'
  pod 'Alamofire','~> 4.9.1'
  pod 'CryptoSwift', '~> 1.3.8'
  pod 'BigInt', '~> 4.0'
  pod 'SwiftyTesseract', '~> 3.1.3'
  pod 'OpenSSL-Universal', '~> 1.1.180'
  pod 'Firebase/Crashlytics', '~> 8.12.0'
  pod 'Firebase/Analytics', '~> 8.12.0'
  pod 'WebAuthnKit', :git => 'https://github.com/1KBlockID/WebAuthnKit-iOS.git', :tag => '2.0.2'
  pod 'EllipticCurveKeyPair', :git => 'https://github.com/1KBlockID/EllipticCurveKeyPair.git', :tag => '2.0.2'
  pod 'Web3', :git => 'https://github.com/Boilertalk/Web3.swift.git', :tag => '0.4.2'
  pod 'YubiKit', '~> 4.2.0'

end
post_install do |installer|
 installer.pods_project.targets.each do |target|
  target.build_configurations.each do |config|
    config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
   # set build library for distribution to true
    config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'

  end
 end
end
