# Splitter

![Splitter](https://splitter.mberk.com/splitter-smaller.png)

A native Speedrunning timer for macOS

**[FAQ](https://github.com/MichaelJBerk/Splitter/wiki/FAQ)**

**[Tips](https://github.com/MichaelJBerk/Splitter/wiki/Tips)**

**[Tip Jar](https://mberk.com/donate/)**

## Download

### Stable

The latest stable release of Splitter is available on the Mac App Store:

[Download Latest Stable Release](https://apps.apple.com/us/app/splitter-speedrun-timer/id1502505482?ls=1)

## Beta Testing

If you're a _"thrill seeker"_, want to help test the next version of Splitter, or just like living on the edge, you can try out the latest beta release, which is based on the `dev` branch

[Download Latest Beta](https://testflight.apple.com/join/UtXpw5Gja)

If you can't use TestFlight, [download from the Releases page](https://github.com/MichaelJBerk/Splitter/releases)

## Discussion 

You can suggest features, report issues, and contribute to the overall discussion about Splitter on the official [Discord Server](https://discord.gg/S6zCHYq). 

## Supported Formats

[Info about Splitter's native file format](https://github.com/MichaelJBerk/Splitter/wiki/.Split-Format)

In addition to the Splitter-native `.split` format, the app can edit and save the following:
	- LiveSplit (`.lss`)
	- Splits.io (`.json`)
	
Note that some features (such as appearance and color settings) are only saved to a `.split` file. As such, if you don't want to have to set them every time you open the file, it's recommended to save the file as `.split` (by clicking "File" -> "Save as..." in the menubar). If you need to need to share it with someone who isn't using Splitter, just open the `.split` file, and save it in whatever other format works best.  
	
## Building Splitter

If you want to build Splitter yourself:
- Install CocoaPods if you don't already have it installed
- Clone this repo
- run `pod install` in the project's root directory
- Open Splitter.xcworkspace in Xcode

In order for certain features to work - namely Splits.io authentications, and beta updates via Sparkle - you'll need to replace the keys in `Config.xcconfig` with your own personal keys - see that file for more info.


### Acknowledgements
[LiveSplit Core](https://github.com/LiveSplit/livesplit-core)

[Splits.io](https://splits.io/)

[Files by John Sundell](https://github.com/JohnSundell/Files)

[MASShortcut by Vadim Shpakovski](https://github.com/shpakovski/MASShortcut)

[Preferences by Sindre Sorhus](https://github.com/sindresorhus/Preferences) 

[Sparkle by Sparkle Project](https://github.com/sparkle-project/Sparkle)

[Cocoapods](https://cocoapods.org)

[Microsoft App Center](https://appcenter.ms)
