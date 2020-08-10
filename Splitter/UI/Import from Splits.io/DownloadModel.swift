//
//  DownloadModel.swift
//  Splitter
//
//  Created by Michael Berk on 8/10/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import SplitsIOKit
import Cocoa

class DownloadModel {
	var splitsIO: SplitsIOKit
	
	init(splitsIOURL: URL? = nil) {
		if let url = splitsIOURL {
			splitsIO = SplitsIOKit(url: url)
		} else {
			splitsIO = SplitsIOKit()
		}
		
	}
	var game: SplitsIOGame?
}
