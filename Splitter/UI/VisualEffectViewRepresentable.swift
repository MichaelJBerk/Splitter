//
//  VisualEffectViewRepresentable.swift
//  Splitter
//
//  Created by Michael Berk on 7/15/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import SwiftUI
import Cocoa
import AppKit
struct VisualEffectBackground: NSViewRepresentable {
	private let material: NSVisualEffectView.Material
	private let blendingMode: NSVisualEffectView.BlendingMode
	private let isEmphasized: Bool
	
	fileprivate init(
		material: NSVisualEffectView.Material,
		blendingMode: NSVisualEffectView.BlendingMode,
		emphasized: Bool) {
		self.material = material
		self.blendingMode = blendingMode
		self.isEmphasized = emphasized
	}
	
	func makeNSView(context: Context) -> NSVisualEffectView {
		let view = NSVisualEffectView()
		
		// Not certain how necessary this is
		view.autoresizingMask = [.width, .height]
		
		return view
	}
	
	func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
		nsView.material = material
		nsView.blendingMode = blendingMode
		nsView.isEmphasized = isEmphasized
	}
}

@available(macOS 10.15, *)
struct VisualEffect: ViewModifier {
	@State var material: NSVisualEffectView.Material
	@State var blendingMode: NSVisualEffectView.BlendingMode = .behindWindow
	@State var emphasized: Bool = false
	func body(content: Content) -> some View {
		content
		.background(VisualEffectBackground(
			material: material,
			blendingMode: blendingMode,
			emphasized: emphasized))
	}
}
