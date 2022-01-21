//
//  LSKit.swift
//  LiveSplitKit
//
//  Created by Michael Berk on 1/21/22.
//

import Foundation

public func updateLayoutState(_ layout: Layout, timer: LSTimer) -> String {
	let state = layout.state(timer)
	let refMutState = LayoutStateRefMut(ptr: state.ptr)
	let json = layout.updateStateAsJson(refMutState, timer)
	return json
}

class CThing {
	func hey() {
		print("hello, worldb")
	}
}
