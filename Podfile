# Uncomment the next line to define a global platform for your project
 platform :ios, '15.0'

target '1Kosmos Demo' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for 1Kosmos Demo
  pod 'Toast-Swift', '~> 5.0.1'
  pod 'Firebase/Crashlytics', '~> 8.12.0'
  pod 'Firebase/Analytics', '~> 8.12.0'
#  pod 'BlockID', :git => 'https://github.com/1KBlockID/ios-blockidsdk.git', :tag => '1.20.51'

pod 'secp256k1.swift'
pod 'TrustWalletCore', '~> 2.5.6'
pod 'Alamofire','~> 4.9.1'
pod 'CryptoSwift', '~> 1.6.0'
pod 'BigInt', '~> 4.0'
pod 'OpenSSL-Universal', '~> 1.1.2300'

end

post_install do |installer|
 installer.pods_project.targets.each do |target|
  target.build_configurations.each do |config|

   # set build active architecture to to YES
    config.build_settings['ONLY_ACTIVE_ARCH'] = 'YES'
  
   # set build library for distribution to true
    config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'

   # enable simulator support
    config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64 i386"
    
    # set iOS Deployment Target to 15.0
    config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
    
    # Settings for support of Xcode 15
    xcconfig_path = config.base_configuration_reference.real_path
    xcconfig = File.read(xcconfig_path)
    xcconfig_mod = xcconfig.gsub(/DT_TOOLCHAIN_DIR/, "TOOLCHAIN_DIR")
    File.open(xcconfig_path, "w") { |file| file << xcconfig_mod }
  end
 end
end
