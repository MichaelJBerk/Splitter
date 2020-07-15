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

struct WelcomeView: View {
	@State var selectKeeper: URL? = nil
	var fileURLs = NSDocumentController.shared.recentDocumentURLs
    var body: some View {
		HStack {
			SplitterInfoView()
				.frame(maxWidth: .infinity, maxHeight: .infinity)
			RecentsView(fileURLs: fileURLs, selectKeeper: $selectKeeper)
				.frame(width: 309)
				
		}
		.frame(width: 800, height: 460)
    }
}

struct RecentsView: View {
	var listStrs: [String] {
		let urls = NSDocumentController.shared.recentDocumentURLs
		var strs: [String] = []
		for url in urls {
			let fileName = url.lastPathComponent
			strs.append(fileName)
		}
		return strs
	}
	var fileURLs: [URL]
	@Environment(\.controlActiveState) var focusthing: ControlActiveState
	
	@Binding var selectKeeper: URL?
	var body: some View {
		List(fileURLs, id: \.self, selection: $selectKeeper) { url in
			FileRow(url: url, selectedURL: $selectKeeper)
				

				
				
				
		}
		.listRowBackground(Color.red)
		
		
		.listStyle(SidebarListStyle())
		
		
	}
}

struct FileRow: View {
	var url: URL
	//Using hit testing to ensure that clicking on it anywhere in the row selects it (otherwise, clicking the text/image wouldn't select it).
	//If it was always false, then the custom gesture (to open the file) wouldn't work, so I had to get creative
	var shouldHitTest: Bool {
		if selectedURL != url {
			return false
		}
		return true
	}
	var icon: NSImage {
		let format = DocFileType.fileExtension(fileExtension: url.pathExtension)
		switch format {
		case .liveSplit:
			return NSImage(contentsOf: Bundle.main.url(forResource: "livesplit", withExtension: "icns")!)!
		case .splitFile:
			return NSImage(contentsOf: Bundle.main.url(forResource: "SplitterDocIcon", withExtension: "icns")!)!
		case .splitsioFile:
			return NSImage(contentsOf: Bundle.main.url(forResource: "Splitter Doc SplitsIO", withExtension: "icns")!)!
		}
	}
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
			if selectedURL == url {
				
			NSDocumentController.shared.openDocument(withContentsOf: url, display: true, completionHandler: {_,_,_ in
				(NSApp.delegate as? AppDelegate)?.welcomeWindow.close()
			})
			}
		}), including: .gesture)
		.padding([.top, .bottom], 5)
		.frame(maxHeight: 50)
		
		.contentShape(Rectangle())
	}
	
	func fileName() -> String {
		if let r = url.lastPathComponent.range(of: #"^([^.]+)"#, options: .regularExpression) {
			let s = url.lastPathComponent[r]
			return String(s)
		}
		return ""
	}
	func filePath() -> String {
		let u = url.deletingLastPathComponent().relativeString.replacingOccurrences(of: "file://", with: "").replacingOccurrences(of: "/Volumes/", with: "").removingPercentEncoding
		
		return u ?? ""
	}
}

struct WelcomeButtonStyle: ButtonStyle {
	func makeBody(configuration: Self.Configuration) -> some View {
		configuration.label
			.buttonStyle(BorderlessButtonStyle())
			.foregroundColor(configuration.isPressed ? .secondary : .primary)
	}
}
struct CreateNewFileButton: View {
	
	var body: some View {
		Button(action: {
			NSDocumentController.shared.newDocument(nil)
			(NSApplication.shared.delegate as? AppDelegate)?.welcomeWindow.close()
		}, label: {
			HStack {
				Text("􀑍").font(.system(size: 30))
					
					.foregroundColor(.blue)
				VStack(alignment: .myAlignment) {
					Text("New Run").font(.headline)
					Text("Start a new speedrun").font(.subheadline)
				}
				.alignmentGuide(.myAlignment) { d in d[HorizontalAlignment.center]}
				
			}
		}).buttonStyle(WelcomeButtonStyle())
	}
}

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
//				.frame(maxWidth:40)
//				.padding(.leading, 10)
			VStack(alignment: .myAlignment) {
				Text("Open an existing run").font(.headline)
				Text("Open an existing .Split, LiveSplit, or Splits.io file on your Mac").font(.subheadline)
			}
			.alignmentGuide(.myAlignment) { d in d[HorizontalAlignment.center]}
//				10
//			}
		}
		}).buttonStyle(WelcomeButtonStyle())
	}
}
struct DownloadFileButton: View {
	var body: some View {
		Button(action: {}, label: {
		HStack {
			Text("􀈅").font(.system(size: 30))
				.foregroundColor(.blue)
//				.frame(maxWidth:40)
//				.padding(.leading, 10)
			VStack(alignment: .myAlignment) {
				Text("Download a run from Splits.io").font(.headline)
				Text("Download a run from the one and only Splits.io ").font(.subheadline)
			}
			.alignmentGuide(.myAlignment) { d in d[HorizontalAlignment.center]}
//				10
//			}
		}
		}).buttonStyle(WelcomeButtonStyle())
	}
}

extension HorizontalAlignment {
	private enum MyAlignment : AlignmentID {
		static func defaultValue(in d: ViewDimensions) -> CGFloat {
			return d[.leading]
		}
	}
	static let myAlignment = HorizontalAlignment(MyAlignment.self)
}


struct SplitterInfoView: View {
	@State var selectKeeper: Int? = nil
	@State var buttonHover: Bool = false
	var body: some View {
		VStack {
			HStack() {
				Button(buttonHover ? "􀁡" :"􀁠") {
					NSApplication.shared.keyWindow?.close()
				}
				.buttonStyle(BorderlessButtonStyle())
				.padding([.leading], /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
				.onHover { hovering in
					buttonHover = hovering
				}
				Spacer()
				
			}
			Spacer()
				.frame(height: 50.0)
			Image(nsImage: NSApplication.shared.applicationIconImage)
				
			Text("Welcome to Splitter").font(.largeTitle)
				
			Text("The Speedrunning timer for macOS").font(.subheadline)
			VStack(alignment: .leading, spacing: 10) {
				Spacer()
					.frame(height: 15)
				CreateNewFileButton()
					OpenFileButton()
					DownloadFileButton()
					.onTapGesture {
						let frame = NSApplication.shared.keyWindow?.frame
						print("width: \(frame?.width)")
						print("height: \(frame?.height)")
					}
			}
			
			Spacer()
			
		}
		
	}
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
