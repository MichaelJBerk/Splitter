//
//  SplitsIOUpload.swift
//  Splitter
//
//  Created by Michael Berk on 8/16/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Foundation
import SplitsIOKit
extension ViewController {
	func uploadToSplitsIO() {
		if let runString = makeSplitsIOJSON(),
			SplitsIOKit.shared.hasAuth {
			let confAlert = NSAlert()
			confAlert.messageText = "Are you sure you would like to upload this run to Splits.io?"
			confAlert.addButton(withTitle: "Upload")
			confAlert.addButton(withTitle: "Cancel")
			confAlert.beginSheetModal(for: view.window!, completionHandler: { response in
				if response == .alertFirstButtonReturn {
					let loadingView = LoadingViewController()
					loadingView.loadViewFromNib()
					loadingView.labelView.stringValue = "Uploading..."
					self.presentAsSheet(loadingView)
					try? SplitsIOKit.shared.uploadRunToSplitsIO(runString: runString, completion: { claimURI in
						
						self.dismiss(loadingView)
						let finishedAlert = NSAlert()
						finishedAlert.messageText = "Run has successfully been uploaded to Splits.io"
						finishedAlert.addButton(withTitle: "OK")
						finishedAlert.addButton(withTitle: "View on Splits.io")
						finishedAlert.beginSheetModal(for: self.view.window!, completionHandler: { response2 in
							if response2 == .alertSecondButtonReturn {
								print(claimURI)
								NSWorkspace.shared.open(URL(string: claimURI)!)
							}
						})
					})
				}
			})
		} else {
			if !SplitsIOKit.shared.hasAuth {
				let notLoggedInAlert = NSAlert()
				notLoggedInAlert.messageText = "Splitter is not signed in to Splits.io"
				notLoggedInAlert.informativeText = "Log in with your Splits.io account to upload"
				notLoggedInAlert.addButton(withTitle: "Log in")
				notLoggedInAlert.addButton(withTitle: "Cancel")
				notLoggedInAlert.beginSheetModal(for: self.view.window!, completionHandler: { response in
					if response == .alertFirstButtonReturn {
						AppDelegate.shared?.preferencesWindowController.show(preferencePane: .splitsIO)
					}
				})
			}
		}
	}
	func makeSplitsIOJSON() -> String? {
		let timer = SplitsIOTimer(shortname: "Splitter", longname: "Splitter", website: "https://mberk.com/splitter", version: "v\(otherConstants.version) (\(otherConstants.build))")
		let game = SplitsIORunCategory(longname: self.runTitle, shortname: nil, links: nil)
		let cat = SplitsIORunCategory(longname: self.category, shortname: nil, links: nil)
		var cs: [SplitsIOSegment] = []
		for s in self.currentSplits {
			let best = s.bestSplit.TSToMil()
			let dur = SplitsIOBestDuration(realtimeMS: best, gametimeMS: best)
			let seg = SplitsIOSegment(name: s.splitName, endedAt: dur, bestDuration: dur, isSkipped: nil, histories: nil)
			cs.append(seg)
		}
		var runners: [SplitsIOExchangeRunner] = []
		if let currentRunner = Settings.splitsIOUser {
			let r = SplitsIOExchangeRunner(links: nil, longname: currentRunner.displayName, shortname: currentRunner.name)
			runners.append(r)
		}
		let sIO = SplitsIOExchangeFormat(schemaVersion: "v1.0.1", links: nil, timer: timer, attempts: nil, game: game, category: cat, runners: runners, segments: cs, imageURL: nil)
		if var jsonString = try? sIO.jsonString() {
			return jsonString.replacingOccurrences(of: "schemaVersion", with: "_schemaVersion")
		}
		return nil
	}
}
