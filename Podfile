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
    
    target 'SplitterTests' do 
      splitter_pods
    end
  
    target 'SplitterUITests' do 
      splitter_pods
  end
  
  post_install do |installer|
    installer.generated_projects.each do |project|
      project.targets.each do |target|
          target.build_configurations.each do |config|
              config.build_settings['MACOSX_DEPLOYMENT_TARGET'] = '10.15'
           end
      end
      puts "Fix MASShortcut"
    end
  end
  
end