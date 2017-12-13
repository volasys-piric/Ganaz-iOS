# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Ganaz' do
  # Uncomment the next line if you're using Swift or would like to use dynamic frameworks
  use_frameworks!

  # Pods for Ganaz
  
  pod 'AFNetworking'
  pod 'IQKeyboardManager'
  pod 'UIView+Shake'
  pod 'SVProgressHUD'
  pod 'OneSignal'
  pod 'SVPullToRefresh'
  pod 'GoogleMaps'
  pod 'HCSStarRatingView'
  pod 'Mixpanel'
  pod 'Fabric'
  pod 'Crashlytics'
  pod 'TTTAttributedLabel'
  pod 'UITextView+Placeholder', '~> 1.2'
  pod 'GrowingTextView'
  pod 'Branch'
  # pod 'SlackTextViewController'
  
  #pod 'PNChart'
  
  post_install do |installer|
      installer.pods_project.targets.each do |target|
          target.build_configurations.each do |config|
              config.build_settings['SWIFT_VERSION'] = '4.0'
          end
      end
  end
  
end
