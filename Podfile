# Uncomment the next line to define a global platform for your project
platform :osx, '10.15'
  use_frameworks!



target 'Splitter' do
  # Comment the next line if you don't want to use dynamic frameworks
  	pod 'Preferences', :git => 'https://github.com/sindresorhus/Preferences.git', :branch => 'bigsur'
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
class Pod::Target::BuildSettings::AggregateTargetSettings
    alias_method :ld_runpath_search_paths_original, :ld_runpath_search_paths

    def ld_runpath_search_paths
        return ld_runpath_search_paths_original unless configuration_name == "Debug"
        return ld_runpath_search_paths_original + framework_search_paths
    end
end

class Pod::Target::BuildSettings::PodTargetSettings
    alias_method :ld_runpath_search_paths_original, :ld_runpath_search_paths

    def ld_runpath_search_paths
        return (ld_runpath_search_paths_original || []) + framework_search_paths
    end
end