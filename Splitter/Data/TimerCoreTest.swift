//
//  TimerCoreTest.swift
//  Splitter
//
//  Created by Michael Berk on 3/2/21.
//  Copyright © 2021 Michael Berk. All rights reserved.
//

import SwiftUI

@available(macOS 11.0, *)
struct TimerCoreTest: View {
	
	var timerCore: SplitterRun
	@State var selected: CSplit? = nil
	var timerLabel: String {
		let timer = timerCore.codableLayout.components[2].timer!
		return "\(timer.time)\(timer.fraction)"
	}
	
    var body: some View {
//
//			.padding()
//			.frame(maxWidth: .infinity, maxHeight: .infinity)
		VStack {
			List(timerCore.codableLayout.components[1].splits!.splits, id: \.self, selection: $selected) { (i: CSplit) in
				HStack {
					if (i.name.count > 0) {
						Text(i.name)
					} else {
						Text("blank")
					}
					if (i.columns.count > 0) {
						Text(i.columns[0].value)
					}
				}
				.border(Color.red)
			}
			HStack {
				Text("\(timerLabel)")
				Spacer()
				Button("+") {
					let newSeg = SplitTableRow(splitName: "NewRow!", bestSplit: .init(), currentSplit: .init(), previousSplit: .init(), previousBest: .init())
					let tc = timerCore
					tc.addSegment(segment: newSeg)
				}
				Button("Start") {
					timerCore.timer.splitOrStart()
				}
//				Button("Split") {
//					timerCore.timer.split()
//				}
				Button("getState") {
					print(timerCore.timer.lsTimer.currentPhase())
					print(timerCore.timer.lsTimer.getRun().len())
				}
				
			}
		}
		.padding()
		.frame(minWidth: 500, maxWidth: .infinity, minHeight: 500, maxHeight: .infinity)
    }
}
@available(macOS 11.0, *)
struct TimerCoreTest_Previews: PreviewProvider {
	static var cLayout: CLayout {
		let run = SplitterRun(run: Run())
		return run.codableLayout
	}
    static var previews: some View {
		
		TimerCoreTest(timerCore: SplitterRun(run: Run()))
    }
}
