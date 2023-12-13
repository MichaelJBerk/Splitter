//
//  FontManager.swift
//  Splitter
//
//  Created by Michael Berk on 12/13/23.
//  Copyright © 2023 Michael Berk. All rights reserved.
//

import Cocoa
import LiveSplitKit

///Object that manages the fonts for a run
class FontManager {
	
	///The run to manage
	private var run: SplitterRun
	
	init(run: SplitterRun) {
		self.run = run
	}
	
	private var undoManager: UndoManager? {
		self.run.undoManager
	}
	
	private var codableLayout: CLayout! {
		self.run.codableLayout
	}
	
	
	private func getFont(font: KeyPath<FontManager, NSFont?>, fontSize:KeyPath<FontManager, CGFloat>,  fixedFontSize: Bool, defaultSize: CGFloat) -> NSFont {
		var size = defaultSize
		if !fixedFontSize {
			size += self[keyPath: fontSize]
		}
		if let font = self[keyPath: font],
		   let adjusted = NSFont(name: font.fontName, size: size) {
			return adjusted
		}
		return NSFont.systemFont(ofSize: size)
	}
	
	//MARK: - Text Font
	
	///Property storing underlying font used for labels in the run window
	///
	///The font stored in this property is used by ``getTextFont(fixedFontSize:defaultSize:)``, ``textFontSize``, and ``setTextFont(to:)``
	///
	///- Important: You cannot set this field directly. Instead, use ``setTextFont(to:)`` to change it.
	private var textFont: NSFont?
	
	
	///Size adjustment for the Text font
	///
	///This property is used by ``getTextFont(fixedFontSize:defaultSize:)``
	var textFontSize: CGFloat = 0 {
		didSet {
			NotificationCenter.default.post(name: .fontChanged, object: self.run)
		}
	}
	
	/// Sets the text font to the given `LiveSplitFont`
	///
	/// - Parameter lsFont: Font to set the timer font to
	/// - NOTE: If a valid NSFont can't be generated from the given `LiveSplitFont`, the default system font will be used instead
	func setTextFont(to lsFont: LiveSplitFont?) {
		let oldLSFont = codableLayout.textFont
		undoManager?.registerUndo(withTarget: self, handler: { run in
			run.setTextFont(to: oldLSFont)
		})
		undoManager?.setActionName("Set Text Font")
		if let lsFont, let font = lsFont.toNSFont() {
			run.editLayout({$0.setGeneralSettingsValue(3, .fromFont(lsFont)!)})
			self.textFont = font
		} else {
			run.editLayout{$0.setGeneralSettingsValue(3, .fromEmptyFont())}
			self.textFont = nil
		}
		NotificationCenter.default.post(name: .fontChanged, object: self.run)
	}
	
	/// Retrieves the font to use for labels in run window
	///
	/// This property is analagous to the `textFont` in LiveSplitCore.
	///
	/// Unlike LiveSplit, this does not control the font for the splits component header. The splits component header uses ``splitsFont``
	/// - Parameters:
	///   - fixedFontSize: whether to just use `defaultSize`, or adjust it according to ``textFontSize``
	///   - defaultSize: Baseline text size to use for the font. If `fixedFontSize` is false, it will be adjusted by ``textFontSize``
	/// - Returns: The text font, adjusted according to the igven parameters
	func getTextFont(fixedFontSize: Bool, defaultSize: CGFloat = NSFont.systemFontSize) -> NSFont {
		return getFont(font: \.textFont, fontSize: \.textFontSize, fixedFontSize: fixedFontSize, defaultSize: defaultSize)
	}
	
	//MARK: - Timer Font
	
	///Property storing underlying font used for the timer component
	///
	///The font stored in this property is used by ``getTimerFont(fixedFontSize:defaultSize:)``, ``textFontSize``, and ``setTimerFont(to:)``
	///
	///- Important: You cannot set this field directly. Instead, use ``setTimerFont(to:)`` to change it.
	private var timerFont: NSFont?
	
	/// Sets the timer font to the given `LiveSplitFont`
	///
	/// - Parameter lsFont: Font to set the timer font to
	/// - NOTE: If a valid NSFont can't be generated from the given `LiveSplitFont`, the default system font will be used instead
	func setTimerFont(to lsFont: LiveSplitFont?) {
		let oldLSFont = codableLayout.timerFont
		undoManager?.registerUndo(withTarget: self, handler: { run in
			run.setTimerFont(to: oldLSFont)
		})
		undoManager?.setActionName("Set Timer Font")
		if let lsFont, let font = lsFont.toNSFont() {
			run.editLayout { $0.setGeneralSettingsValue(1, .fromFont(lsFont)!)}
			self.timerFont = font
		} else {
			run.editLayout {$0.setGeneralSettingsValue(1, .fromEmptyFont())}
			self.timerFont = nil
		}
		NotificationCenter.default.post(name: .fontChanged, object: self.run)
	}
	
	/// Retrieves the font used for the timer component
	///
	/// This property is analagous to the `timerFont` in LiveSplitCore.
	///
	/// - Parameters:
	///   - fixedFontSize: whether to just use `defaultSize`, or adjust it according to ``textFontSize``
	///   - defaultSize: Baseline text size to use for the font. If `fixedFontSize` is false, it will be adjusted by ``textFontSize``
	/// - Returns: The times font, adjusted according to the igven parameters
	func getTimerFont(fixedFontSize: Bool, defaultSize: CGFloat) -> NSFont {
		let font =  getFont(font: \.timerFont, fontSize: \.textFontSize, fixedFontSize: fixedFontSize, defaultSize: defaultSize)
		//Do this to prevent timer font from getting too big
		return NSFontManager.shared.convert(font, toSize: defaultSize)
	}
	
	//MARK: - Splits Font
	
	
	///Font used for the Splits component
	///
	///Property storing underlying font used for the Splits component.
	///
	///The font stored in this property is used by ``getSplitsFont(fixedFontSize:defaultSize:)``, ``splitsFontSize``, and ``setSplitsFont(to:)``
	private var splitsFont: NSFont?

	
	///Size adjustment for the Splits font
	///
	///This property is used by ``getSplitsFont(fixedFontSize:defaultSize:)``
	var splitsFontSize: CGFloat = 0 {
		didSet {
			NotificationCenter.default.post(name: .fontChanged, object: self.run)
		}
	}
	
	/// Sets the splits font to the given `LiveSplitFont`
	///
	/// - Parameter lsFont: Font to set the splits font to.
	/// - NOTE: If a valid NSFont can't be generated from the given `LiveSplitFont`, the default system font will be used instead
	func setSplitsFont(to lsFont: LiveSplitFont?) {
		let oldLSFont = codableLayout.timesFont
		undoManager?.registerUndo(withTarget: self, handler: { run in
			run.setSplitsFont(to: oldLSFont)
		})
		if let lsFont, let font = lsFont.toNSFont(size: NSFont.systemFont(ofSize: 13).pointSize + splitsFontSize) {
			run.editLayout({$0.setGeneralSettingsValue(2, .fromFont(lsFont)!)})
			self.splitsFont = font
		} else {
			run.editLayout{$0.setGeneralSettingsValue(2, .fromEmptyFont())}
			self.splitsFont = nil
		}
		NotificationCenter.default.post(name: .fontChanged, object: self.run)
	}
	
	/// Retrieves the font to use for labels in run window
	///
	///
	/// This property is analagous to the `timesFont` in LiveSplitCore.
	///
	/// - Parameters:
	///   - fixedFontSize: whether to just use `defaultSize`, or adjust it according to ``splitsFontSize``
	///   - defaultSize: Baseline text size to use for the font. If `fixedFontSize` is false, it will be adjusted by ``splitsFontSize``
	/// - Returns: The splits font, adjusted according to the igven parameters
	func getSplitsFont(fixedFontSize: Bool, defaultSize: CGFloat = NSFont.systemFontSize) -> NSFont {
		return getFont(font: \.splitsFont, fontSize: \.splitsFontSize, fixedFontSize: fixedFontSize, defaultSize: defaultSize)
	}
}
