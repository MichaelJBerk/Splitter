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
import Introspect

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
		HStack(spacing: 0) {
			ZStack {
				Color(NSColor.windowBackgroundColor)
					.edgesIgnoringSafeArea(.all)
				SplitterInfoView()
			}
				.frame(maxWidth: .infinity, maxHeight: .infinity)
			RecentsView(fileURLs: fileURLs, selectedURL: $selectedURL)
				.modifier(FirstResponderModifier())
				.frame(width: 309)
				.padding([.top, .bottom], listPadding)
				
		}
		.frame(width: 800, height: 470)
    }
}

/**
Attempts to make the given view the first responder.

This is implemented so that the default selection in the Recents list has the correct background color.
*/
@available (macOS 10.15, *)
struct FirstResponderModifier: ViewModifier {
	func body(content: Content) -> some View {
		content
			.introspect(selector: { introspectionView in
				guard let viewHost = Introspect.findViewHost(from: introspectionView) else { return nil }
				return Introspect.previousSibling(containing: NSView.self, from: viewHost)
			}, customize: {$0.becomeFirstResponder()})
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
				.contextMenu(menuItems: {
					Button("Show in Finder") {
						NSWorkspace.shared.activateFileViewerSelecting([url])
					}
				})
				.listRowInsets(.init(top: 2.5, leading: 5, bottom: 2.5, trailing: 5))
		}
		.listStyle(SidebarListStyle())
		//This is what triggers the button's action when clicked
		.onReceive(NotificationCenter.default.publisher(for: .init("RecentButtonClick")), perform: { notification in
			if let url = notification.userInfo?["url"] as? URL {
				self.openFile(url: url)
			}
		})
		.onAppear(perform: {
			if let firstURL = fileURLs.first,
			   selectedURL == nil {
				self.selectedURL = firstURL
			}
			//In order so that pressing the enter key triggers the button's action, we use a custom subclass of of `NSWindow` - `KeyDownWindow`, lets me customize the behavior of the `keyDown` function using the code below.
			//For more info, see the documentation on `KeyDownWindow`.
			AppDelegate.shared?.welcomeWindow.keyDownBehavior = { event in
				if event.keyCode == 36, let sURL = selectedURL {
					self.openFile(url: sURL)
					return false
				}
				return true
			}
		})
	}
	func openFile(url: URL) {
		NSDocumentController.shared.openDocument(withContentsOf: url, display: true, completionHandler: {_,_,_ in
			(NSApp.delegate as? AppDelegate)?.welcomeWindow.close()
		})
	}
}
@available(macOS 10.15, *)
/// Row for the RecentsView
struct RecentsRow: View {
	/// The file's path on the user's machine
	var url: URL
	/**
	Configures whether or not the label or icon should recieve user interations (i.e. clicks)
	
	Hit testing is used to ensure that clicking anywhere in the row selects it (otherwise, clicking the text/image wouldn't select it). When `false`, the image and label will pass interactions to the row itself, instead of hogging them for themseleves.
	If it was always `false`, then the custom gesture (to open the file) wouldn't work.
	*/
	var shouldHitTest: Bool {
		if selectedURL != url {
			return false
		}
		return true
	}
	///Image to represent the file, depending on its file type
	var icon: NSImage {
		let format = DocFileType.fileType(for: url.pathExtension)
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
		Button(action: {
			NotificationCenter.default.post(.init(name: .init("RecentButtonClick"), object: nil, userInfo: ["url": self.url]))
		}, label: {
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
				
				AdaptiveVStack(alignment: .leading) {
					Spacer()
					Text(fileName()).font(.headline).fontWeight(.regular)
					Text(filePath()).font(.caption).truncationMode(.head)
					Spacer()
				}
				.allowsHitTesting(shouldHitTest)
			}
			
			.contentShape(Rectangle())
		})
		.buttonStyle(PlainButtonStyle())
		.allowsHitTesting(shouldHitTest)
		.frame(maxHeight: 40)
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

@available(macOS 10.15, *)
struct AdaptiveVStack<Content: View>: View {
	@State var alignment: HorizontalAlignment = .center
	@State var spacing: CGFloat? = nil
	@ViewBuilder var content: () -> Content

	var body: some View {
		Group {
			if #available(macOS 11.0, *) {
				LazyVStack(alignment: alignment, spacing: spacing, pinnedViews: .init(), content: content)
			} else {
				VStack(alignment: alignment, spacing: spacing, content: content)
			}
		}
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
				Image("plus.app")
					.resizable()
					.aspectRatio(contentMode: .fit)
					.frame(width: 30)
					.foregroundColor(.accentColor)
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
			Image("folder")
				.resizable()
				.aspectRatio(contentMode: .fit)
				.frame(width: 30)
				.foregroundColor(.accentColor)
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
			Image("square.and.arrow.down.fill")
				.resizable()
				.aspectRatio(contentMode: .fit)
				.frame(width: 30, height: 30)
				.foregroundColor(.accentColor)
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
	func mainView(showOnLaunch: Binding<Bool>) -> some View {
		VStack {
			Spacer()
			Image(nsImage: NSApplication.shared.applicationIconImage)
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
	
	var body: some View {
		let showOnLaunch = Binding<Bool>(
			get: {self.showWelcomeScreenOnLaunch}, set: {self.showWelcomeScreenOnLaunch = $0})
		return mainView(showOnLaunch: showOnLaunch)
	}
}

/**
A window with a customizable KeyDown function.

We use this so that pressing the enter key on the Welcome window triggers the button press.

# Why?

- We can't use the `.keyboardShortcut` modifier because it's unsupported on 10.15, and only works if you use the SwiftUI App Lifecycle
- Can't use a local event monitor because there's no reliable way to get rid of it
**/

class KeyDownWindow: NSWindow {
	//if true, fall back to default behavior
	var keyDownBehavior: (NSEvent) -> Bool = {_ in return false}
	override func keyDown(with event: NSEvent) {
		let b = keyDownBehavior(event)
		if b {
			super.keyDown(with: event)
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
