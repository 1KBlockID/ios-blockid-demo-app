# Uncomment the next line to define a global platform for your project
 platform :ios, '11.0'

target 'BlockIDTestApp' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for BlockIDTestApp
  pod 'TrustWalletCore', '~> 2.5.6'
  pod 'Alamofire','~> 4.9.1'
  pod 'CryptoSwift', '~> 1.3.0'
  pod 'BigInt', '~> 4.0'
  pod 'SwiftyTesseract', '~> 3.1.3'
  pod 'OpenSSL-Universal', '~> 1.1.180'
  pod 'Toast-Swift', '~> 5.0.1'
end


post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|

      # build active architecture only
      config.build_settings['ONLY_ACTIVE_ARCH'] = 'YES'

      # set iOS Deployment Target to 11.0
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
    end
  end
end
