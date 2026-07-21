# Uncomment the next line to define a global platform for your project
 platform :ios, '16.0'

target '1Kosmos Demo' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for 1Kosmos Demo
  pod 'Toast-Swift', '~> 5.1.1'
  pod 'Firebase/Crashlytics', '~> 12.14.0'
  pod 'Firebase/Analytics', '~> 12.14.0'
end

post_install do |installer|
 installer.pods_project.targets.each do |target|
  target.build_configurations.each do |config|

   # set build library for distribution to true
    config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'

    # set iOS Deployment Target to 16.0
    config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '16.0'
    
    # Settings for support of Xcode 15
    xcconfig_path = config.base_configuration_reference.real_path
    xcconfig = File.read(xcconfig_path)
    xcconfig_mod = xcconfig.gsub(/DT_TOOLCHAIN_DIR/, "TOOLCHAIN_DIR")
    File.open(xcconfig_path, "w") { |file| file << xcconfig_mod }
  end
 end
end
