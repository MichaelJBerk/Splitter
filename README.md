# Splitter

![Splitter](https://mberk.com/splitter.png)

A native Speedrunning timer for macOS

Splitter is officially in Beta, but you can test it out with the link below, and give feedback.

[Download Latest Beta Build](https://install.appcenter.ms/users/mjosephberk/apps/splittertest/distribution_groups/public%20beta)

If you'd like to see what features are in the works, you can look at the [Roadmap](https://github.com/MichaelJBerk/Splitter/wiki/Roadmap)

[Join the Slack group](https://join.slack.com/t/splitter-app/shared_invite/enQtOTQ4OTg3OTg3NTQwLTNlMjAyZjZlNzgzNzhkNTMwOTA2MjZkODNlMzM3ZDYwZjY1YTc2ODljZWQzMzJjYjAzOWEwNzU0MWFmODQ3NjM)

[Info about the `.Split`format](https://github.com/MichaelJBerk/SplitterFormats)

## Formats & Files

### Splits
- In addition to the Splitter-native `.split` format, the app can import the following:
	- Splits.io Exchange Format (`.json`)
	- LiveSplit (`.lss`)
	

The app can also export to `.json`, and exporting to `.lss` will come in a future build 
Support for additional formats is currently underway 

### Hotkeys
- Hotkeys are stored in `~/Library/Application Support/Splitter/splitter.splitKeys`, with a `.json` file for each configured hotkey. 
	- Note: If the filenames are changed, the app won’t recognize it.  

### Acknowledgements
[LiveSplit Core](https://github.com/LiveSplit/livesplit-core)

[Files by John Sundell](https://github.com/JohnSundell/Files)

[Hotkey by Sam Soffes](https://github.com/soffes/HotKey)

[Preferences by Sindre Sorhus](https://github.com/sindresorhus/Preferences) 

[Sparkle by Sparkle Project](https://github.com/sparkle-project/Sparkle)

[Cocoapods](https://cocoapods.org)

[Microsoft App Center](https://appcenter.ms)
