# Uncomment the next line to define a global platform for your project
 platform :ios, '15.0'

target '1Kosmos Demo' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for 1Kosmos Demo
  pod 'Toast-Swift', '~> 5.0.1'
  pod 'Firebase/Crashlytics', '~> 8.12.0'
  pod 'Firebase/Analytics', '~> 8.12.0'
  pod 'BlockID', :git => 'https://github.com/1KBlockID/ios-blockidsdk.git', :tag => '1.20.56'
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
    
    # Add Privacy Manifest to Alamofire target (CI/CD safe)
    if target.name == 'Alamofire'

      # Source manifest file from your project bundle
      source_privacy_file_path = File.join(Dir.pwd, 'PrivacyInfo.xcprivacy')

      # Destination path inside Pods/Alamofire (your original path)
      privacy_file_path = File.join(installer.sandbox.root, target.name, 'PrivacyInfo.xcprivacy')

      # Copy existing manifest file to Alamofire pod folder
      if File.exist?(source_privacy_file_path)

        system("cp #{source_privacy_file_path} #{privacy_file_path}")

        puts "✅ Copied PrivacyInfo.xcprivacy from bundle to Alamofire pod"

        # Add file to Alamofire target resources (required for archive)
        file_ref = installer.pods_project.main_group.new_file(privacy_file_path)

        unless target.resources_build_phase.files_references.include?(file_ref)
          target.resources_build_phase.add_file_reference(file_ref, true)
          puts "✅ Added PrivacyInfo.xcprivacy to Alamofire target resources"
        end

      else
        puts "❌ PrivacyInfo.xcprivacy not found at #{source_privacy_file_path}"
      end

    end
########
# Save Pods project
installer.pods_project.save
  end
 end
end
