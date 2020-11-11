//
//  WelcomeView.swift
//  Splitter
//
//  Created by Michael Berk on 7/14/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import SwiftUI
import Cocoa
import Files

@available(macOS 10.15, *)
/// View that prompts the user to open a new file, open an existing file, or import a file from Splits.io
struct WelcomeView: View {
	var listPadding: CGFloat {
		if #available(macOS 11.0, *) {
			return 0
		} else {
			return 10
		}
	}
	/// URL for the currently selected file in the recents list
	@State var selectedURL: URL? = nil
	/// Array of the user's most recently opened documents
	var fileURLs = NSDocumentController.shared.recentDocumentURLs
    var body: some View {
		HStack {
			SplitterInfoView()
				.frame(maxWidth: .infinity, maxHeight: .infinity)
			RecentsView(fileURLs: fileURLs, selectedURL: $selectedURL)
				.frame(width: 309)
				.padding([.top, .bottom], listPadding)
				
		}
		.frame(width: 800, height: 460)
    }
}
// MARK: - Recents List (Right Side)
@available(macOS 10.15, *)
/// View that displays the user's most recently opened documents
struct RecentsView: View {
	/// URLs to display in the list
	var fileURLs: [URL]
	/// URL for the currently selected file in the recents list
	@Binding var selectedURL: URL?
	var body: some View {
		List(fileURLs, id: \.self, selection: $selectedURL) { url in
			RecentsRow(url: url, selectedURL: self.$selectedURL)
				
		}
		.listRowBackground(Color.red)
		.listStyle(SidebarListStyle())
		
	}
}
@available(macOS 10.15, *)
/// Row for the RecentsView
struct RecentsRow: View {
	/// The file's path on the user's machine
	var url: URL
	/// Configures whether or not the label or icon should recieve user interations (i.e. clicks)
	///
	/// Hit testing is used to ensure that clicking anywhere in the row selects it (otherwise, clicking the text/image wouldn't select it). When false, the image and label will pass interactions to the row itself, instead of hogging them for themseleves.
	/// If it was always false, then the custom gesture (to open the file) wouldn't work.
	var shouldHitTest: Bool {
		if selectedURL != url {
			return false
		}
		return true
	}
	///Image to represent the file, depending on its file type
	var icon: NSImage {
		let format = DocFileType.fileExtension(fileExtension: url.pathExtension)
		switch format {
		case .liveSplit:
			return NSImage(contentsOf: Bundle.main.url(forResource: "SplitterDocLSS", withExtension: "icns")!)!
		case .splitFile:
			return NSImage(named: "splitDocIcon")!
        case .splitsioFile:
			return NSImage(contentsOf: Bundle.main.url(forResource: "SplitterDocSplitsio", withExtension: "icns")!)!
		}
	}
	///The currently selected URL
	@Binding var selectedURL: URL?
	var body: some View {
		HStack(alignment: .center) {
			VStack{
				Spacer()
				Image(nsImage: icon)
					.resizable()
					.aspectRatio(contentMode: .fit)
					.frame(height: 25, alignment: .center)
				Spacer()
			}
			.allowsHitTesting(shouldHitTest)
			
			VStack(alignment: .leading) {
				Spacer()
				Text(fileName()).font(.subheadline)
				Text(filePath()).truncationMode(.head)
				Spacer()
			}
			.allowsHitTesting(shouldHitTest)
			
		}
		.simultaneousGesture(TapGesture().onEnded({
			if self.selectedURL == self.url {
				
				NSDocumentController.shared.openDocument(withContentsOf: self.url, display: true, completionHandler: {_,_,_ in
				(NSApp.delegate as? AppDelegate)?.welcomeWindow.close()
			})
			}
		}), including: .gesture)
		.padding([.top, .bottom], 5)
		.frame(maxHeight: 50)
		
		.contentShape(Rectangle())
	}
	///Gets the file name used for the label
	func fileName() -> String {
		if let r = url.lastPathComponent.range(of: #"^([^.]+)"#, options: .regularExpression) {
			let s = url.lastPathComponent[r]
			return String(s)
		}
		return ""
	}
	///Gets the file path used for the label
	func filePath() -> String {
		let u = url.deletingLastPathComponent().relativeString.replacingOccurrences(of: "file://", with: "").replacingOccurrences(of: "/Volumes/", with: "").removingPercentEncoding
		
		return u ?? ""
	}
}

//MARK: - Info View (Left Side)
//MARK: Buttons
@available(macOS 10.15, *)
/// Button Style used for buttons in the Welcome window
struct WelcomeButtonStyle: ButtonStyle {
	func makeBody(configuration: Self.Configuration) -> some View {
		configuration.label
			.buttonStyle(BorderlessButtonStyle())
			.foregroundColor(configuration.isPressed ? .secondary : .primary)
	}
}
@available(macOS 10.15, *)
/// Button for the user to create a new file from the Welcome window
struct CreateNewFileButton: View {
	var body: some View {
		Button(action: {
			NSDocumentController.shared.newDocument(nil)
			(NSApplication.shared.delegate as? AppDelegate)?.welcomeWindow.close()
		}, label: {
			HStack {
				Text("􀑍").font(.system(size: 30))
					
					.foregroundColor(.blue)
				VStack(alignment: WelcomeAlignment.welcomeAlignment) {
					Text("New Run").font(.headline)
					Text("Start a new speedrun").font(.subheadline)
				}
				.alignmentGuide(WelcomeAlignment.welcomeAlignment) { d in d[HorizontalAlignment.center]}
				
			}
		}).buttonStyle(WelcomeButtonStyle())
	}
}
@available(macOS 10.15, *)
/// Button for the user to open an existing file from the Welcome window
struct OpenFileButton: View {
	var body: some View {
		Button(action: {
			NSDocumentController.shared.beginOpenPanel(completionHandler: { urls in
				if let urls = urls {
					for url in urls {
						NSDocumentController.shared.openDocument(withContentsOf: url, display: true, completionHandler: { _, _, _ in
							(NSApplication.shared.delegate as? AppDelegate)?.welcomeWindow.close()
						})
					}
				}
				
			})
			
		}, label: {
		HStack {
			Text("􀈕").font(.system(size: 25))
				.foregroundColor(.blue)
			VStack(alignment: WelcomeAlignment.welcomeAlignment) {
				Text("Open an existing run").font(.headline)
				Text("Open an existing .Split, LiveSplit, or Splits.io file on your Mac").font(.subheadline)
			}
			.alignmentGuide(WelcomeAlignment.welcomeAlignment) { d in d[HorizontalAlignment.center]}
		}
		}).buttonStyle(WelcomeButtonStyle())
	}
}
@available(macOS 10.15, *)
/// Button for the user to download a run from Splits.io in the Welcome window
struct DownloadFileButton: View {
	var body: some View {
		Button(action: {
			let board = NSStoryboard(name: "DownloadWindow", bundle: nil).instantiateController(withIdentifier: "windowController") as? DownloadWindowController
			if let win = board?.window {
				AppDelegate.shared?.searchWindow = win
			}
			board?.window?.makeKeyAndOrderFront(nil)
			
			
		}, label: {
		HStack {
			Text("􀈅").font(.system(size: 30))
				.foregroundColor(.blue)
			VStack(alignment: WelcomeAlignment.welcomeAlignment) {
				Text("Download a run from Splits.io").font(.headline)
				Text("Use the splits from an existing run on Splits.io ").font(.subheadline)
			}
			.alignmentGuide(WelcomeAlignment.welcomeAlignment) { d in d[HorizontalAlignment.center]}
			
		}
		}).buttonStyle(WelcomeButtonStyle())
	}
}

@available(macOS 10.15, *)
/// Alignment used for the Welcome window
struct WelcomeAlignment {
	private enum privateWelcomeAlignment: AlignmentID {
		static func defaultValue(in context: ViewDimensions) -> CGFloat {
			return context[.leading]
		}
	}
	static let welcomeAlignment = HorizontalAlignment(privateWelcomeAlignment.self)
}

//MARK: Info View
@available(macOS 10.15, *)
/// View on the left side of the Welcome window
struct SplitterInfoView: View {
	
	/// Whether or not the Welcome screen should be opened upon launch
	///
	/// Modifying this changes the setting in UserDefaults
	@State var showWelcomeScreenOnLaunch: Bool = Settings.showWelcomeWindow {
		didSet {
			Settings.showWelcomeWindow = self.showWelcomeScreenOnLaunch
		}
	}
	
	var body: some View {
		let showOnLaunch = Binding<Bool>(
			get: {self.showWelcomeScreenOnLaunch}, set: {self.showWelcomeScreenOnLaunch = $0})
		return VStack {
			
			Spacer()
            Image(nsImage: NSApplication.shared.applicationIconImage)
//                .fixedSize()
				.aspectRatio(contentMode: .fit)
				
			Text("Welcome to Splitter").font(.largeTitle)
				
			Text("The Speedrunning timer for macOS").font(.subheadline)
            Spacer()
            VStack(alignment: .leading, spacing: 20) {
				Spacer()
					.frame(height: 15)
				CreateNewFileButton()
				OpenFileButton()
				DownloadFileButton()
				HStack {
					Button("Configure Hotkeys"){
						(NSApp.delegate as? AppDelegate)?.preferencesWindowController.show(preferencePane: .hotkeys)
					}
					Toggle("Show this screen on startup", isOn: showOnLaunch)
						.toggleStyle(CheckboxToggleStyle())
				}
				Spacer()
					.frame(height: 10)
			}
			
		}
		
		
	}
}
//MARK: - Previews
@available(macOS 10.15, *)
struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
