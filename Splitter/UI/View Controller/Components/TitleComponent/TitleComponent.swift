//
//  MetadataView.swift
//  Splitter
//
//  Created by Michael Berk on 4/20/21.
//  Copyright © 2021 Michael Berk. All rights reserved.
//

import Cocoa

class TitleComponent: NSStackView, SplitterComponent, NibLoadable {
	var run: SplitterRun!
	
	
	let showInfoButtonKey = "showInfoButton"
	var showInfoButton: Bool {
		get {
			!infoButton.isHidden
		}
		set {
			infoButton.isHidden = !newValue
		}
	}
	
	func saveState() throws -> ComponentState {
		var state = saveBasicState()
		state.properties[showInfoButtonKey] = showInfoButton
		return state
	}
	
	func loadState(from state: ComponentState) throws {
		loadBasicState(from: state.properties)
		showInfoButton = (state.properties[showInfoButtonKey] as? JSONAny)?.value as? Bool ?? true
	}
	internal override func awakeAfter(using coder: NSCoder) -> Any? {
		return instantiateView() // You need to add this line to load view
	}
	var optionsView: NSView! {
		let d = defaultComponentOptions() as! ComponentOptionsVstack
		let check = ComponentOptionsButton(checkboxWithTitle: "Show Options button", clickAction: {_ in 
			self.showInfoButton.toggle()
		})
		check.state = .init(bool: showInfoButton)
		d.addArrangedSubview(check)
		return d
	}
	
	static func instantiateView(run: SplitterRun) -> TitleComponent {
		let tc: TitleComponent = TitleComponent.instantiateView()
		tc.run = run
		tc.setup()
		return tc
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
	 }
	func setup() {
		gameTitleField.delegate = self
		gameSubtitleField.delegate = self
		gameTitleField.run = run
		gameIconButton.run = run
		gameSubtitleField.run = run
		infoButton.run = run
		infoButton.image = nil
		if #available(macOS 11.0, *) {
			infoButton.image = NSImage(systemSymbolName: "gearshape.fill", accessibilityDescription: nil)
		} else {
			infoButton.image = NSImage(named: "gearshape")
		}
	}
	
	@objc func iconChanged() {
		
	}
	
	///Sets up the placeholder icon.
	func setupDefaultGameIcon() {
		
		///Can't do this in `setup` because viewController hasn't been initalized yet.
		gameIconButton.run = viewController.run
		if let gi = viewController.run.gameIcon {
			gameIconButton.image = gi
		} else {
			gameIconButton.image = .gameControllerIcon
		}
	}
	
	var customSpacing: CGFloat? = nil
	
	var viewController: ViewController!
	
	var isSelected: Bool = false {
		didSet {
			didSetSelected()
		}
	}
	
	@IBOutlet weak var gameTitleField: ThemedTextField!
	@IBOutlet weak var gameSubtitleField: ThemedTextField!
	@IBOutlet weak var infoButton: ThemedButton!
	@IBAction func infoButtonClick(_ sender: Any) {
		viewController?.showInfoPanelMenuItem(sender)
	}
	@IBOutlet weak var gameIconButton: MetadataImage!
	
}
extension TitleComponent: NSTextFieldDelegate {
	@objc func controlTextDidEndEditing(_ obj: Notification) {
//		if (oldTitle != gameTitleField.stringValue || oldSubtitle != gameSubtitleField.stringValue) {
		viewController.run.title = self.gameTitleField.stringValue
		viewController.run.subtitle = self.gameSubtitleField.stringValue
//
//			viewController.undoManager?.registerUndo(withTarget: self, selector: #selector(controlTextDidEndEditing(_:)), object: run.title)
//			viewController.run.title = gameTitleField.stringValue
//			viewController.run.subtitle = gameSubtitleField.stringValue
//		}
	}
//	@objc func setRunTitle(_ title: String) {
//		if title != run.title {
//			viewController.undoManager?.registerUndo(withTarget: self, selector: #selector(setRunTitle(_:)), object: viewController.run.title)
//			viewController.run.title = title
//			gameTitleField.stringValue = run.title
//		}
//	}
//	@objc func setRunSubtitle(_ subtitle: String) {
//		if subtitle != run.subtitle {
//			viewController.undoManager?.registerUndo(withTarget: self, selector: #selector(setRunSubtitle(_:)), object: viewController.run.subtitle)
//			viewController.run.subtitle = subtitle
//			gameTitleField.stringValue = run.subtitle
//		}
//	}
	
	func updateTextFields() {
		let t = run.title
		gameTitleField.stringValue = t
		gameSubtitleField.stringValue = run.subtitle
	}
}
