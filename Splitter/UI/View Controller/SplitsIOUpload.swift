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
		if let runString = makeSplitsIOJSON() {
			try? SplitsIOKit.shared.uploadRunToSplitsIO(runString: runString, completion: {
				
			})
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
		let sIO = SplitsIOExchangeFormat(schemaVersion: "v1.0.1", links: nil, timer: timer, attempts: nil, game: game, category: cat, runners: runners, segments: cs)
		if var jsonString = try? sIO.jsonString() {
			return jsonString.replacingOccurrences(of: "schemaVersion", with: "_schemaVersion")
		}
		return nil
	}
}
