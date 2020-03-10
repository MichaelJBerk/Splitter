//
//  ImportExportSplitsIO.swift
//  Splitter
//
//  Created by Michael Berk on 1/24/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Foundation
import Cocoa
import Files
//MARK: Import/Export splits.io data from .json

extension ViewController {
	///Handles importing data froma splits.io .json file, from creating a dialog box to choose the file, to actually importing it
	@IBAction func importSplitsio(_ sender: Any) {
			let dialog = NSOpenPanel();
			dialog.title                   = "Choose a .json file";
			dialog.showsResizeIndicator    = true;
			dialog.showsHiddenFiles        = false;
			dialog.canChooseDirectories    = true;
			dialog.canCreateDirectories    = true;
			dialog.allowsMultipleSelection = false;
			dialog.allowedFileTypes        = ["json"];

			if (dialog.runModal() == NSApplication.ModalResponse.OK) {
				let result = dialog.url // Pathname of the file
			   
				if (result != nil) {
					self.parseSplitsIO(result!.path)
				}
			} else {
				//Clicked "Cancel"
		}
	}
				
				
	func parseSplitsIO(_ path: String) {
					
		loadedFilePath = path
		let pathURL = URL(fileURLWithPath: path)
		do {
			let jsonData = try Data(contentsOf: pathURL)
			let newJSONDecoder = JSONDecoder()
			let splitsIO = try? newJSONDecoder.decode(SplitsIOExchangeFormat.self, from: jsonData)
			//SplitsIOExchangeFormat(jsonData, links: nil, timer: nil)
			runTitleField.stringValue = splitsIO!.game!.longname!
			categoryField.stringValue = splitsIO!.category!.longname!
			currentSplits = []
	//						loadedSplits = []
			let exportJSON = view.window?.menu?.item(withTag: 1)
			exportJSON?.isEnabled = true
			//Loading of json into TimeSplits
			
			
			for sT in (splitsIO?.segments!)! {
				let splitTitle = sT.name!
				let bestSplitIO = sT.bestDuration?.realtimeMS
				let currentSplitIO = sT.endedAt?.realtimeMS
				let bestTS = TimeSplit(mil: bestSplitIO!)
				let currentTS = TimeSplit(mil: currentSplitIO!)
				//TODO: Update to new split behavior
				var newTableRow = splitTableRow(splitName: splitTitle, bestSplit: bestTS, currentSplit: currentTS, previousSplit: currentTS, previousBest: bestTS)
				
				
	//							loadedSplits.append(newTableRow)
				currentSplits.append(newTableRow)
				
			}
			shouldLoadSplits = true
			self.splitsIOData = splitsIO
			splitsTableView.reloadData()

		} catch {
			
		}
	}
		///Handles exporting data to a splits.io .json file
		@IBAction func exportToSplitsIO(_ sender: Any) {
			var newSegments: [SplitsIOSegment]? = []
			
			for s in currentSplits {
				let name = s.splitName
				let endedAt = SplitsIOBestDuration(realtimeMS: s.currentSplit.TSToMil(), gametimeMS: 0)
				let bestDuration = SplitsIOBestDuration(realtimeMS: s.bestSplit.TSToMil(), gametimeMS: 0)
				let histories: [JSONAny]? = []
				let newSegment = SplitsIOSegment(name: name, endedAt: endedAt, bestDuration: bestDuration, isSkipped: false, histories: histories)
				newSegments?.append(newSegment)
			}
			var newSplitsIOData: SplitsIOExchangeFormat? = nil
			if splitsIOData != nil {
				newSplitsIOData = SplitsIOExchangeFormat(schemaVersion: splitsIOData.schemaVersion,
															 links: splitsIOData.links,
															 timer: splitsIOData.timer,
															 attempts: splitsIOData.attempts,
															 game: splitsIOData.game,
															 category: splitsIOData.category,
															 runners: splitsIOData.runners,
															 segments: newSegments)
			} else {
				let links = SplitsIOExchangeFormatLinks()
				let timer = SplitsIOTimer(shortname: "exchange", longname: "Splits.io Echange Format", website: "https://github.com/glacials/splits-io/tree/master/public/schema", version: "")
				let histories: [JSONAny]? = []
				let attempts = SplitsIOAttempts(total: 0, histories: histories)
				let game = SplitsIOCategory(longname: runTitleField.stringValue, shortname: runTitleField.stringValue, links: nil)
				let category = SplitsIOCategory(longname: categoryField.stringValue, shortname: categoryField.stringValue, links: nil)
				
				newSplitsIOData = SplitsIOExchangeFormat(schemaVersion: "v1.0.1", links: links, timer: timer, attempts: attempts, game: game, category: category, runners: nil, segments: newSegments)
			}
			let newJSONEncoder = JSONEncoder()
			let encodedSplitsIO = try? newJSONEncoder.encode(newSplitsIOData!)
			
			let dialog = NSSavePanel()
			dialog.title = "Save to Splits.io"
			dialog.allowedFileTypes = ["json"]
			dialog.allowsOtherFileTypes = false
		
			if let w = view.window {
				dialog.beginSheetModal(for: w) { (response) in
					if response == .OK {
						let path = dialog.url?.lastPathComponent
						
						let folderPath = dialog.directoryURL?.path
						var newFile = try? Folder(path: folderPath!).createFileIfNeeded(withName: path!)
						try? newFile?.write(encodedSplitsIO!)
						
						
					}
				}
			}
			
		}
}
