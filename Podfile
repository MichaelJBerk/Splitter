# Uncomment the next line to define a global platform for your project
platform :osx, '10.14'
  use_frameworks!

  def splitter_pods
  	pod 'Sparkle'
  	pod 'MASShortcut'
  end
  
  target 'Splitter' do 
    splitter_pods
  end
  target 'SplitterTests' do 
    splitter_pods
  end
  	
  
  target 'SplitterUITests' do 
    splitter_pods
  end
  	
# target 'SplitterTests' do
# 	 inherit! :search_paths
# end

plugin 'cocoapods-keys', {
  :project => "Splitter",
  :target => ["Splitter", "SplitterTests", "SplitterUITests"],
  :keys => [
    "AppCenter",
    "edKey",
    "splitsiosecret",
    "splitsioclient"
  ]
}
# end