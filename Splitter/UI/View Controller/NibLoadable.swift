//
//  NibLoadable.swift
//  Splitter
//
//  Created by Michael Berk on 6/25/21.
//  Copyright © 2021 Michael Berk. All rights reserved.
//

import Cocoa

///The newer, better Nib loading protocol
protocol NibLoadable {
	static var nibName: String? { get }
	static func createFromNib(in bundle: Bundle) -> Self?
}

extension NibLoadable where Self: NSView {

	static var nibName: String? {
		return String(describing: self)
	}

	static func createFromNib(in bundle: Bundle = Bundle.main) -> Self? {
		guard let nibName = nibName else { return nil }
		var topLevelArray: NSArray? = nil
		bundle.loadNibNamed(NSNib.Name(nibName), owner: self, topLevelObjects: &topLevelArray)
		guard let results = topLevelArray else { return nil }
		let views = Array<Any>(results).filter { $0 is Self }
		return views.last as? Self
	}
}

extension NibLoadable where Self: NSViewController {

	static var nibName: String? {
		return String(describing: self)
	}

	static func createFromNib(in bundle: Bundle = Bundle.main) -> Self? {
		guard let nibName = nibName else { return nil }
		var topLevelArray: NSArray? = nil
		bundle.loadNibNamed(NSNib.Name(nibName), owner: self, topLevelObjects: &topLevelArray)
		guard let results = topLevelArray else { return nil }
		let views = Array<Any>(results).filter { $0 is Self }
		return views.last as? Self
	}
}
