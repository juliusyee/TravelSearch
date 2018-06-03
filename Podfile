# Uncomment the next line to define a global platform for your project
 platform :ios, '11.0'

target 'TravelSearch' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for TravelSearch
  pod 'Alamofire'
  pod 'AlamofireSwiftyJSON'
  pod 'EasyToast'
  pod 'McPicker'
  pod 'Cosmos', '~> 15.0'
  pod 'SwiftSpinner'
  pod 'GooglePlaces'
  pod 'GooglePlacePicker'
  pod 'GoogleMaps'
  pod 'TwitterKit'

  post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
  	config.build_settings.delete('CODE_SIGNING_ALLOWED')
	config.build_settings.delete('CODE_SIGNING_REQUIRED')
    end
  end

end
