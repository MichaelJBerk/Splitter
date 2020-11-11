//
//  ActivityIndicatorRepresentable.swift
//  Splitter
//
//  Created by Michael Berk on 7/20/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import SwiftUI
@available(macOS 10.15, *)
struct ActivityIndicator: NSViewRepresentable {

	@Binding var isAnimating: Bool
	var frame: NSRect
	var style: NSProgressIndicator.Style

	func makeNSView(context: NSViewRepresentableContext<ActivityIndicator>) -> NSProgressIndicator {
		let pView = NSProgressIndicator(frame: frame)
		pView.isIndeterminate = true
		pView.style = style
		return pView
	}

	func updateNSView(_ nsView: NSProgressIndicator, context: NSViewRepresentableContext<ActivityIndicator>) {
		nsView.style = style
		isAnimating ? nsView.startAnimation(nil) : nsView.stopAnimation(nil)
		
	}
}
