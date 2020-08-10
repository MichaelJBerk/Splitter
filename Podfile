# Uncomment the next line to define a global platform for your project
platform :osx, '10.15'
  use_frameworks!



target 'Splitter' do
  # Comment the next line if you don't want to use dynamic frameworks
  	pod 'Preferences'
  	pod 'AppCenter'
  	pod 'Sparkle'
  	pod 'MASShortcut'
  	
# target 'SplitterTests' do
# 	 inherit! :search_paths
# end

plugin 'cocoapods-keys', {
  :project => "Splitter",
  :target => "Splitter",
  :keys => [
    "AppCenter",
    "edKey"
  ]
}
end