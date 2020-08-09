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
//		nsView.material = context.environment.visualEffectMaterial ?? material
		
//		nsView.blendingMode = context.environment.visualEffectBlending ?? blendingMode
//		nsView.isEmphasized = context.environment.visualEffectEmphasized ?? isEmphasized
	}
}
@available(macOS 10.15, *)
extension View {
	func visualEffect(
		material: NSVisualEffectView.Material,
		blendingMode: NSVisualEffectView.BlendingMode = .behindWindow,
		emphasized: Bool = false
	) -> some View {
		background(
			VisualEffectBackground(
				material: material,
				blendingMode: blendingMode,
				emphasized: emphasized
			)
		)
	}
}
