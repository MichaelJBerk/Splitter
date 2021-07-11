//
//  LoadableNib.swift
//  Splitter
//
//  Created by Michael Berk on 6/17/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Cocoa
///USed for NSViewController
protocol LoadableNib {
    var contentView: NSView! { get }
}

extension LoadableNib where Self: NSView {
	func loadViewFromNib() {
        let bundle = Bundle(for: type(of: self))
        let nib = NSNib(nibNamed: .init(String(describing: type(of: self))), bundle: bundle)!
        _ = nib.instantiate(withOwner: self, topLevelObjects: nil)

        let contentConstraints = contentView.constraints
        contentView.subviews.forEach({ addSubview($0) })

        for constraint in contentConstraints {
            let firstItem = (constraint.firstItem as? NSView == contentView) ? self : constraint.firstItem
            let secondItem = (constraint.secondItem as? NSView == contentView) ? self : constraint.secondItem
            addConstraint(NSLayoutConstraint(item: firstItem as Any, attribute: constraint.firstAttribute, relatedBy: constraint.relation, toItem: secondItem, attribute: constraint.secondAttribute, multiplier: constraint.multiplier, constant: constraint.constant))
        }
    }
}
extension LoadableNib where Self: NSViewController {
	func loadViewFromNib() {
		let bundle = Bundle(for: type(of: self))
		let nib = NSNib(nibNamed: .init(String(describing: type(of: self))), bundle: bundle)!
		_ = nib.instantiate(withOwner: self, topLevelObjects: nil)
		self.viewDidLoad()
	}
}
extension NSView {
	///Instantiates the given view from its `xib`
	///The trick with this is to use the root view of the XIB as the custom class - NOT file's owner
	public static func instantiateView<View: NSView>(for type: View.Type = View.self) -> View {
		let bundle = Bundle(for: type)
		let nibName = String(describing: type)

		guard bundle.path(forResource: nibName, ofType: "nib") != nil else {
			return View(frame: .zero)
		}

		var topLevelArray: NSArray?
		bundle.loadNibNamed(NSNib.Name(nibName), owner: nil, topLevelObjects: &topLevelArray)
		guard let results = topLevelArray as? [Any],
			let foundedView = results.last(where: {$0 is Self}),
			let view = foundedView as? View else {
				fatalError("NIB with name \"\(nibName)\" does not exist.")
		}
		return view
	}
	public func instantiateView() -> NSView {
		guard subviews.isEmpty else {
			return self
		}

		let loadedView = NSView.instantiateView(for: type(of: self))
		loadedView.frame = frame
		loadedView.autoresizingMask = autoresizingMask
		loadedView.translatesAutoresizingMaskIntoConstraints = translatesAutoresizingMaskIntoConstraints

		loadedView.addConstraints(constraints.compactMap { ctr -> NSLayoutConstraint? in
			guard let srcFirstItem = ctr.firstItem as? NSView else {
				return nil
			}

			let dstFirstItem = srcFirstItem == self ? loadedView : srcFirstItem
			let srcSecondItem = ctr.secondItem as? NSView
			let dstSecondItem = srcSecondItem == self ? loadedView : srcSecondItem

			return NSLayoutConstraint(item: dstFirstItem,
									  attribute: ctr.firstAttribute,
									  relatedBy: ctr.relation,
									  toItem: dstSecondItem,
									  attribute: ctr.secondAttribute,
									  multiplier: ctr.multiplier,
									  constant: ctr.constant)
		})

		return loadedView
	}
}
