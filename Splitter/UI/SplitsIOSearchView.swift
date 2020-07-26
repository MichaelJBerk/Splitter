//
//  SplitsIOSearchView.swift
//  Splitter
//
//  Created by Michael Berk on 7/15/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import SwiftUI
import SplitsIOKit
import Introspect
import Combine

extension List {
	func removeBG() -> some View {
		return introspectTableView { tableView in
			  tableView.backgroundColor = .clear
			  tableView.enclosingScrollView!.drawsBackground = false
			}
	}
}
enum SearchWindowView {
	case searchForGame
	case chooseCategory
	case finish
}
extension View {
   func conditionalModifier<Content: View>(_ conditional: Bool, content: (Self) -> Content) -> some View {
		if conditional {
			return AnyView(content(self))
		} else {
			return AnyView(self)
		}
	}
}

struct SplitsIOSearchView: View {
	
	@State var selectedRun: String?
	@EnvironmentObject var model: SearchViewModel

	var showThirdView = false
	
	
    var body: some View {
		currentView
			.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
	var currentView: some View {
		VStack {
			if model.currentViewMode == .searchForGame {
				searchView()
			} else if model.currentViewMode == .chooseCategory {
				ChooseRunView()
			} else {
				FinishView()
			}
		}
		.padding(.horizontal, 5)
		.padding(.bottom, 10)
			
		
	}
}

class SearchViewModel: ObservableObject {
	var sIOKit: SplitsIOKit
	init() {
		sIOKit = SplitsIOKit()
		cancel = AnyCancellable($searchText.removeDuplicates()
									.debounce(for: 0.5,scheduler: DispatchQueue.main)
									.sink(receiveValue: { _ in
										self.editChanged()
									}))
	}
	var cancel: AnyCancellable?
	@Published var searchText: String = ""
	
	func editChanged() {
		sIOKit.searchSplitsIO(for: searchText, completion: { games in
			if let games = games {
				self.options = games
			}
		})
	}
	@Published var options: [SplitsIOGame] = []
	@Published var selectedGame: SplitsIOGame? = nil
	@Published var selectedRun: SplitsIOCat? = nil
	@Published var currentViewMode: SearchWindowView = .searchForGame
	@Published var isLoading = false
	@Published var vcToLoad: NSViewController? = nil
	
	
}

struct searchView: View {
	
	@EnvironmentObject var model: SearchViewModel
	
	var body: some View {
		
		VStack {
			TextField("Search for a game", text: $model.searchText)
				.textFieldStyle(RoundedBorderTextFieldStyle())
			
			List(model.options, id: \.self, selection: $model.selectedGame) { game in
					Text(game.name)
			}
			.border(Color(.darkGray), width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
			.frame(maxHeight: .infinity)
			
			HStack {
				Spacer()
				
				Button(action:{
					self.model.currentViewMode = .chooseCategory
					
				}, label: {
					Text("Next")
				})//.disabled(model.selectedGame == nil)
			}
		}
	}
}

struct FinishView: View {
	@EnvironmentObject var model: SearchViewModel
	@State var animateSpinner: Bool = true
	var body: some View {
		VStack {
			Text("")
			ZStack {
				if model.isLoading {
					loadingView
				} else {
					importCompleteView
				}
			}.frame(maxWidth: .infinity, maxHeight: .infinity)
			.background(Color(.controlBackgroundColor))
			HStack {
				Spacer()
				Button(action: {self.model.isLoading.toggle()}) {
					Text("Toggle Loading")
				}
				Button(action: {
					(NSApp.delegate as? AppDelegate)?.searchWindow.close()
					self.model.vcToLoad?.view.window?.makeKeyAndOrderFront(nil)
				}, label: {
					Text("Finish")
				}).disabled(model.isLoading)
			}
		}
	}
	var importCompleteView: some View {
		VStack {
			Text("Import Complete").font(.title)
			Text("􀁢").font(.system(size: 50))
				.foregroundColor(.green)
			
		}
	}
	var loadingView: some View {
		VStack {
			Text("Downloading").font(.title)
			ActivityIndicator(isAnimating: self.$animateSpinner, frame: NSRect(x: 0, y: 0, width: 50, height: 50), style: .spinning)
		}
	}
}


struct ChooseRunView: View {
	var runs: [String] = ["Any%", "100%"]
	@EnvironmentObject var model: SearchViewModel
	var body: some View {
		
			VStack {
			
				HStack {
					Text("Choose a run")
					Spacer()
				}
				.padding(.top, 10)
				.padding(.leading, /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
				
				List(model.selectedGame?.categories ?? [], id:\.self, selection: $model.selectedRun) { (cat: SplitsIOCat) in
					Text(cat.name)
				}
				.border(Color(.darkGray), width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
				.frame(maxHeight: .infinity)
				Spacer()
				HStack {
					Spacer()
					Button(action:{
						self.model.currentViewMode = .searchForGame
					}, label: {
						Text("Previous")
					})
					Button(action: {
						self.model.isLoading = true
						self.model.currentViewMode = .finish
						DispatchQueue.global(qos: .background).async {
							self.model.selectedRun?.getRun(completion: { run in
								let d = lss()
								let url = URL(string: run!)!
								d.tempURL = url
								NSDocumentController.shared.addDocument(d)
								d.makeWindowControllers()
								if let vc =  d.windowControllers.first?.window?.contentViewController as? ViewController {
									self.model.vcToLoad = vc
									self.model.isLoading = false
							}
						})
						}
					}, label: {Text("Next")})
			}
		}
		
	}
}

struct FinishView_Previews: PreviewProvider {
	static var previews: some View {
		FinishView(animateSpinner: false)
	}
}

//
//struct SplitsIOSearchView_Previews: PreviewProvider {
//	static var previews: some View {
//		SplitsIOSearchView().environmentObject(SearchViewModel())
//			.previewDisplayName("SplitsIO Search View")
//	}
//}
//struct SplitsIOSearchViewWindow_Previews: PreviewProvider {
//	static var previews: some View {
////		SplitsIOSearchView()
////			.previewDisplayName("SplitsIO Search View")
//		Group {
//			Text("empty")
//		}
//			.onAppear {
//				(NSApp.delegate as? AppDelegate)?.createSearchWindow()
//			}
//	}
//}
//struct ChooseRunView_Previews: PreviewProvider {
//	static var previews: some View {
//		ChooseRunView(currentViewMode: .constant(.chooseCategory)).environmentObject(SearchViewModel())
//	}
//}
