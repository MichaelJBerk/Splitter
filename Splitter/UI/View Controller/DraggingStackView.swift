//
//  DraggingStackView.swift
//  Splitter
//
//  Created by Michael Berk on 7/5/21.
//  Copyright © 2021 Michael Berk. All rights reserved.
//
//  Adapted from Mark Onyschuk

//
//  DraggingStackView.swift
//  Analysis
//
//  Created by Mark Onyschuk on 2017-02-02.
//  Copyright © 2017 Mark Onyschuk. All rights reserved.
//
import Cocoa

class DraggingStackView: NSStackView {
	
	func moveView(from oldIndex: Int, to newIndex: Int) {
//		views.move(fromOffsets: IndexSet[oldInd], toOffset: <#T##Int#>)
		let viewToMove = views[oldIndex]
		removeArrangedSubview(viewToMove)
		layoutSubtreeIfNeeded()
		
		insertArrangedSubview(viewToMove, at: newIndex)
		layoutSubtreeIfNeeded()
		
	}

//	var isEnabled = true
//
//	// MARK: -
//	// MARK: Update Function
//	var update: (NSStackView, Array<NSView>)->Void = { stack, views in
//		var viewConstraints = [NSView: [NSLayoutConstraint]]()
//		stack.views.forEach {
//			viewConstraints[$0] = $0.constraints
//			stack.removeView($0)
//		}
//
//		views.forEach {
//			stack.addView($0, in: .leading)
//			let comp = $0 as! SplitterComponent
//			stack.setCustomSpacing(comp.afterSpacing, after: $0)
//
//			switch stack.orientation {
//			case .horizontal:
//				$0.topAnchor.constraint(equalTo: stack.topAnchor).isActive = true
//				$0.bottomAnchor.constraint(equalTo: stack.bottomAnchor).isActive = true
//
//			case .vertical:
//					NSLayoutConstraint.activate([
//						comp.leadingConstraint,
//						comp.trailingConstraint
//					])
//			@unknown default:
//				break
//			}
//		}
//	}
//
//
//	// MARK: -
//	// MARK: Event Handling
//	override func mouseDragged(with event: NSEvent) {
////		if isEnabled {
////			let location = convert(event.locationInWindow, from: nil)
////			if let dragged = views.first(where: { $0.hitTest(location) != nil }) {
////				reorder(view: dragged, event: event)
////			}
////		} else {
////			super.mouseDragged(with: event)
////		}
//
//	}
//
//	private func reorder(view: NSView, event: NSEvent) {
//		guard let layer = self.layer else { return }
//		guard let cached = try? self.cacheViews() else { return }
//
//		let container = CALayer()
//		container.frame = layer.bounds
//		container.zPosition = 1
//		container.backgroundColor = NSColor.underPageBackgroundColor.cgColor
//
//		cached
//			.filter  { $0.view !== view }
//			.forEach { container.addSublayer($0) }
//
//		layer.addSublayer(container)
//		defer { container.removeFromSuperlayer() }
//
//		let dragged = cached.first(where: { $0.view === view })!
//
//		dragged.zPosition = 2
//		layer.addSublayer(dragged)
//		defer { dragged.removeFromSuperlayer() }
//
//		let d0 = view.frame.origin
//		let p0 = convert(event.locationInWindow, from: nil)
//
//		window!.trackEvents(matching: [.leftMouseDragged, .leftMouseUp], timeout: 1e6, mode: RunLoop.Mode.eventTracking) { event, stop in
//			if let event = event {
//				if event.type == .leftMouseDragged {
//					let p1 = self.convert(event.locationInWindow, from: nil)
//
//					let dx = (self.orientation == .horizontal) ? p1.x - p0.x : 0
//					let dy = (self.orientation == .vertical)   ? p1.y - p0.y : 0
//
//					CATransaction.begin()
//					CATransaction.setDisableActions(true)
//					dragged.frame.origin.x = d0.x + dx
//					dragged.frame.origin.y = d0.y + dy
//					CATransaction.commit()
//
//					let reordered = self.views.map {
//						(view: $0,
//						 position: $0 !== view
//							? NSPoint(x: $0.frame.midX, y: $0.frame.midY)
//							: NSPoint(x: dragged.frame.midX, y: dragged.frame.midY))
//					}
//					.sorted {
//						switch self.orientation {
//						case .vertical: return $0.position.y < $1.position.y
//						case .horizontal: return $0.position.x < $1.position.x
//						@unknown default:
//							return false
//						}
//					}
//					.map { $0.view }
//
//					let nextIndex = reordered.firstIndex(of: view)!
//					let prevIndex = self.views.firstIndex(of: view)!
//
//					if nextIndex != prevIndex {
//						self.update(self, reordered)
//						self.layoutSubtreeIfNeeded()
//
//						CATransaction.begin()
//						CATransaction.setAnimationDuration(0.15)
//						CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut))
//
//						for layer in cached {
//							layer.position = NSPoint(x: layer.view.frame.midX, y: layer.view.frame.midY)
//						}
//
//						CATransaction.commit()
//					}
//
//				} else {
//					view.mouseUp(with: event)
//					stop.pointee = true
//				}
//			}
//		}
//	}
//
//	// MARK: -
//	// MARK: View Caching
//	private class CachedViewLayer: CALayer {
//		let view: NSView!
//
//		enum CacheError: Error {
//			case bitmapCreationFailed
//		}
//
//		override init(layer: Any) {
//			self.view = (layer as! CachedViewLayer).view
//			super.init(layer: layer)
//		}
//
//		init(view: NSView) throws {
//			self.view = view
//
//			super.init()
//
//			guard let bitmap = view.bitmapImageRepForCachingDisplay(in: view.bounds) else { throw CacheError.bitmapCreationFailed }
//			view.cacheDisplay(in: view.bounds, to: bitmap)
//
//			frame = view.frame
//			contents = bitmap.cgImage
//		}
//
//		required init?(coder aDecoder: NSCoder) {
//			fatalError("init(coder:) has not been implemented")
//		}
//	}
//
//	private func cacheViews() throws -> [CachedViewLayer] {
//		return try views.map { try cacheView(view: $0) }
//	}
//
//	private func cacheView(view: NSView) throws -> CachedViewLayer {
//		return try CachedViewLayer(view: view)
//	}
}
