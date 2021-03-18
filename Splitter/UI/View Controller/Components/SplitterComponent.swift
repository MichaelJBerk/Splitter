//
//  SplitterComponent.swift
//  Splitter
//
//  Created by Michael Berk on 3/22/21.
//  Copyright © 2021 Michael Berk. All rights reserved.
//

import Foundation

protocol SplitterComponent: NSView {
	var viewController: ViewController? {get set}
}
