//
//  SplitterDocController.swift
//  Splitter
//
//  Created by Michael Berk on 7/8/21.
//  Copyright © 2021 Michael Berk. All rights reserved.
//

import Cocoa
import Files
///Document Controller that supports using runs as templates
///
///This is set as the app's document controller by adding it to `main.storyboard`
class SplitterDocumentController: NSDocumentController {
	
	static var sShared: SplitterDocumentController {
		Self.shared as! SplitterDocumentController
	}
	
	public func makeBlankUntitledDocument(ofType typeName: String) throws -> NSDocument {
		try super.makeUntitledDocument(ofType: typeName)
	}
	
	override func makeUntitledDocument(ofType typeName: String) throws -> NSDocument {
		if templateFileExists {
			let doc: Document = try super.makeUntitledDocument(ofType: typeName) as! Document
			try doc.read(from: doc.folderToFileWrapper(folder: try Folder(path: templateURL.path)), ofType: typeName)
			return doc
		} else {
			return try super.makeUntitledDocument(ofType: typeName)
		}
	}
	
	
	var appSupportURL: URL {
		let url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
		do {
			let appSupportFolder = try Folder(path: url.path)
			let bundleID = Bundle.main.bundleIdentifier!
			try appSupportFolder.createSubfolderIfNeeded(withName: bundleID)
			return try appSupportFolder.subfolder(named: bundleID).url
		} catch {
			print("Error with AppSupportURL: \(error)")
			return URL(string: "")!
		}
	}
	var templateURL: URL {
		appSupportURL.appendingPathComponent("template.split")
	}
	
	var templateFileExists: Bool {
		do {
			return try Folder(path: appSupportURL.path).contains(Folder(path: templateURL.path))
		} catch {
			return false
		}
	}
	func useAsTemplate(doc: SplitterDoc) {
		
		let dialog = NSAlert()
		dialog.addButton(withTitle: "Use as Template")
		dialog.addButton(withTitle: "Cancel")
		dialog.messageText = "Are you sure you want to use this run as the Template run?"
		dialog.informativeText = "By clicking \"Use as Template\", new runs will use the settings, layout, and segments from this run. You can reset it by going to File -> Reset Template Run"
		
		
		if let window = doc.windowControllers.first?.window {
			dialog.beginSheetModal(for: window, completionHandler: { response in
				if response == .alertFirstButtonReturn {
					doc.save(to: self.templateURL, ofType: DocFileType.splitFile.rawValue, for: .saveToOperation, delegate: nil, didSave: nil, contextInfo: nil)
					let followUpAlert = NSAlert()
					followUpAlert.messageText = "Success"
					followUpAlert.informativeText = "New runs will use the settings, layout, and segments from this run"
					followUpAlert.addButton(withTitle: "OK")
					followUpAlert.beginSheetModal(for: window, completionHandler: {_ in})
				}
			})
		}
	}
	
	func resetTemplate() {
		let dialog = NSAlert()
		dialog.messageText = "Are you sure you want to reset the Template run?"
		dialog.informativeText = "By clicking \"Reset\", new runs will use the Splitter's default settings, layout, and segments."
		dialog.addButton(withTitle: "Reset")
		dialog.addButton(withTitle: "Cancel")
		if let window = currentDocument?.windowControllers.first?.window {
			dialog.beginSheetModal(for: window, completionHandler: { response in
				if response == .alertFirstButtonReturn {
					do {
						let templateFile = try Folder(path: self.templateURL.path)
						try templateFile.delete()
						let followupDialog = NSAlert()
						followupDialog.messageText = "Success"
						followupDialog.informativeText = "Template run has been reset successfully"
						followupDialog.beginSheetModal(for: window, completionHandler: {_ in})
					} catch {
						let errorDialog = NSAlert()
						errorDialog.messageText = "Error Resetting Template"
						errorDialog.informativeText = error.localizedDescription
						errorDialog.beginSheetModal(for: window, completionHandler: {_ in})
					}
				}
			})
		}
	}
}
