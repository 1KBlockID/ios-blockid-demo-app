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

   # MOB-7284: Do NOT force ONLY_ACTIVE_ARCH = YES on pods. The app target
   # builds all valid archs in Release (ONLY_ACTIVE_ARCH = NO), so forcing
   # pods to active-arch-only produced an arch mismatch on the simulator
   # ("no such module 'Toast_Swift'"). Let each config use its default
   # (Debug = YES, Release = NO) so pod archs match the consuming app.

   # set build library for distribution to true
    config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'

   # MOB-7284: arm64 simulator slice now ships in BlockID SDK (>= 1.30.60),
   # so the arm64 simulator exclusion workaround is no longer required.
   # Ensure arm64 simulator builds are supported on Apple Silicon.
    config.build_settings.delete("EXCLUDED_ARCHS[sdk=iphonesimulator*]")

   # MOB-7284: Disable Explicitly Built Modules. Xcode 16+ enables this by
   # default, but the Clang module dependency scanner fails to resolve the
   # Firebase umbrella module (Firebase/CoreOnly -> FirebaseCore) during
   # simulator builds ("could not build module 'Firebase'"). Disabling
   # explicit modules restores reliable builds.
    config.build_settings['CLANG_ENABLE_EXPLICIT_MODULES'] = 'NO'
    config.build_settings['SWIFT_ENABLE_EXPLICIT_MODULES'] = 'NO'
    
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
