# Uncomment the next line to define a global platform for your project
platform :osx, '10.14'
  use_frameworks!
  inhibit_all_warnings!

  def splitter_pods
  	pod 'MASShortcut'
    pod 'ZippyJSON'
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