# Uncomment the next line to define a global platform for your project
 platform :ios, '11.0'

target 'BlockIDTestApp' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for BlockIDTestApp
  pod 'Toast-Swift', '~> 5.0.1'
  pod 'BlockIDSDK', :git => 'https://github.com/1KBlockID/ios-blockidsdk.git', :tag => '1.6.10'
end

post_install do |installer|
 installer.pods_project.targets.each do |target|
  target.build_configurations.each do |config|
    
   # set build library for distribution to true
   config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'

  end
 end
end
