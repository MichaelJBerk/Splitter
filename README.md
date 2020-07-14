# Splitter

![Splitter](https://mberk.com/splitter/splitter-smaller.png)

A native Speedrunning timer for macOS

**[FAQ](https://github.com/MichaelJBerk/Splitter/wiki/FAQ)**

**[Tips ("cool things Splitter can do")](https://github.com/MichaelJBerk/Splitter/wiki/Tips)**

**[Tips ("donate")](https://mberk.com/donate/)**

## Download

### Stable

The latest stable release of Splitter is available on the Mac App Store:

[Download Latest Stable Release](https://apps.apple.com/us/app/splitter-speedrun-timer/id1502505482?ls=1)

## Beta Testing

If you want to help test the next version of Splitter (or you just like living on the edge), you can try out the current beta release, which is based on the `dev` branch

[Download Latest Beta](https://install.appcenter.ms/users/mjosephberk/apps/splittertest/distribution_groups/public%20beta)


If you'd like to see what features are in the works, you can look at the [Roadmap](https://github.com/MichaelJBerk/Splitter/wiki/Roadmap)

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
- Clone this repo
- run `pod install` in the project's root directory
	- If prompted for keys, just type in whatever you like and press enter. It won't make a difference to you
- Open Splitter.xcworkspace in Xcode

Note that you'll need to have Cocoapods and Cocoapods-keys installed to build the project

### Acknowledgements
[LiveSplit Core](https://github.com/LiveSplit/livesplit-core)

[Files by John Sundell](https://github.com/JohnSundell/Files)

[MASShortcut by Vadim Shpakovski](https://github.com/shpakovski/MASShortcut)

[Preferences by Sindre Sorhus](https://github.com/sindresorhus/Preferences) 

[Sparkle by Sparkle Project](https://github.com/sparkle-project/Sparkle)

[Cocoapods](https://cocoapods.org)

[Microsoft App Center](https://appcenter.ms)
