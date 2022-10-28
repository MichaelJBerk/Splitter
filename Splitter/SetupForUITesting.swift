//
//  SetupForUITesting.swift
//  Splitter
//
//  Created by Michael Berk on 10/25/22.
//  Copyright © 2022 Michael Berk. All rights reserved.
//

import Foundation
extension AppDelegate {
	
	var isUITesting: Bool {
		return CommandLine.arguments.contains("-uiTesting") 
	}
}
