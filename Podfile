# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'
  use_frameworks!



target 'Splitter' do
  # Comment the next line if you don't want to use dynamic frameworks
  	pod 'Preferences'
  	pod 'AppCenter'
  	pod 'Sparkle'
  	pod 'MASShortcut'

plugin 'cocoapods-keys', {
  :project => "Splitter",
  :target => "Splitter",
  :keys => [
    "AppCenter",
    "edKey"
  ]
}
# post_install do |installer|
# 	# Sign the Sparkle helper binaries to pass App Notarization.
# 	system("codesign --force -o runtime -s 'Developer ID Application' Pods/Sparkle/Sparkle.framework/Resources/Autoupdate.app/Contents/MacOS/Autoupdate")
# 	system("codesign --force -o runtime -s 'Developer ID Application' Pods/Sparkle/Sparkle.framework/Resources/Autoupdate.app/Contents/MacOS/fileop")
# end

end
