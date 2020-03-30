//
//  TimeSplit.swift
//  Splitter
//
//  Created by Michael Berk on 12/22/19.
//  Copyright © 2019 Michael Berk. All rights reserved.
//

import Foundation
import Cocoa

///An object that holds a value of time for a segment.
class TimeSplit: NSCopying, Comparable {
	
	var paused = false
	//Total MS elapsed from start of TimeSplit
	var totalMil = 0
	
	init( mil:Int, sec:Int, min:Int, hour:Int) {

		totalMil = 0
		totalMil = totalMil + mil
		totalMil = totalMil + (sec * 100)
		totalMil = totalMil + (min * 60000)
		totalMil = totalMil + (hour * 3600000)
	}
	
	var mil: Int {
		return totalMil % 100
	}
	var sec: Int {
		
		return Int(totalMil / 100) % 60

	}
	var min: Int {
		return Int(totalMil/6000) % 60

	}
	var hour: Int {

		return totalMil / 360000
	}
	
	
	/// Initalizes the TimeSplit
	/// - Parameter mil: Time of the `TimeSplit`, in milliseconds.
	init (mil: Int) {
		self.totalMil = mil
	}
	
	///Initalizes the time split from using string in the format "00:00:00.00" with hours, minutes, seconds, and milliseconds.
	init(timeString: String) {
		var hourMilSec = timeString.split(separator: ":", maxSplits: 3, omittingEmptySubsequences: false)
		
		if hourMilSec.count == 2 {
			var newTimeString = "00:" + timeString;
			hourMilSec = newTimeString.split(separator: ":", maxSplits: 3, omittingEmptySubsequences: false)
		}
		let secSplit = hourMilSec.last?.split(separator: ".")
	
		hourMilSec.removeLast()
		hourMilSec.append(contentsOf: secSplit!)
		
		if hourMilSec.count == 3 {
			hourMilSec.append("00")
		}
		let finalSplit = hourMilSec
		if hourMilSec.count >= 3 {
			let mil = Int(String(finalSplit[3])) ?? 0
			let sec = Int(String(finalSplit[2])) ?? 0
			let min = Int(String(finalSplit[1])) ?? 0
			let hour = Int(String(finalSplit[0])) ?? 0
			
			totalMil = 0
			totalMil = totalMil + mil
			totalMil = totalMil + (sec * 100)
			totalMil = totalMil + (min * 6000)
			totalMil = totalMil + (hour * 360000)
			
			
		} else {
			self.totalMil = 0
		}
		
	}
	
	///Creates an "empty" TimeSplit, with the time set to 0
	convenience init () {
		self.init(mil: 0)
	}
	
	func reset() {
//		self.mil = 0
//		self.sec = 0
//		self.min = 0
//		self.hour = 0
		self.totalMil = 0
	}
	@objc func updateMil() {
		if !paused {
			totalMil = totalMil + 1
			
		}
	}
	
	/**
	Returns time of the`TimeSplit` as a `String`.
	**/
	var timeString: String {
		
		return String(format: "%.2d:%.2d:%.2d.%.02d", abs(hour), abs(min), abs(sec), abs(mil))
	}
	
	///Returns the `TimeSplit` as a `String`, but only includes the first significant field
	var shortTimeString: String {
//		return timeString
//		return String("\(hour):\(min):\(sec).\(mil)")
//		return String("\(hour):\(min):\(sec).\(mil)")
//		return String(format: "%.2d:%.2d:%.2d.%.02d", hour, min, sec, mil)
		if hour == 0 {
			if min == 0 {
				return String(format: "%.2d.%.2d", abs(sec), abs(mil))
			}
			return String(format: "%.2d:%.2d.%.2d", abs(min), abs(sec), abs(mil))
		}
		return String(format: "%.2d:%.2d:%.2d.%.2d", abs(hour), abs(min), abs(sec), abs(mil))
//		return privateMil.toShortFormattedTimeString()
	}
	
	///Returns a `shortTimeString`, but is rounded to the tenths instead of hundredths
	var shortTimeStringTenths: String {
//		return timeString
//		return String("\(hour):\(min):\(sec).\(mil)")
		//return String("\(hour):\(min):\(sec).\(mil)")
//		return String(format: "%.2d:%.2d:%.2d.%.02d", hour, min, sec, mil)
		let milRounded = Int((Double(mil)/10.00).rounded())
		if hour == 0 {
			if min == 0 {
//
				return String(format: "%.2d.%.1d", abs(sec), abs(milRounded))
			}
			return String(format: "%.2d:%.2d.%.1d", abs(min), abs(sec), abs(milRounded))
		}
		return String(format: "%.2d:%.2d:%.2d.%.1d", abs(hour), abs(min), abs(sec), abs(milRounded))
//		return privateMil.toShortFormattedTimeStringTenths()
	}
	
	
	func frozenTimeSplit() -> TimeSplit {
//		let newTimeSplit = TimeSplit(mil: self.mil, sec: self.sec, min: self.min, hour: self.hour)
		let newTimeSplit = TimeSplit(mil: self.totalMil)
		return newTimeSplit
	}
	
	func copy(with zone: NSZone? = nil) -> Any {
		return TimeSplit(mil: totalMil)
	}
	
	func tsCopy() -> TimeSplit {
		return self.copy() as! TimeSplit
	}
	
	//MARK - Comparable stuff
	
	//Plan - Go through each variable, and see if it's bigger. At the first variable that's bigger, stop.
	
	static func == (lhs: TimeSplit, rhs: TimeSplit) -> Bool {
		if lhs.timeString == rhs.timeString {
			return true
		} else {
			return false
		}
		
	}
	
	static func > (lhs: TimeSplit, rhs: TimeSplit) -> Bool {
//		if lhs.hour > rhs.hour {
//			return true
//		} else {
//			if lhs.min > rhs.min {
//				return true
//			} else {
//				if lhs.sec > rhs.sec {
//					return true
//				} else {
//					if lhs.mil > rhs.mil {
//						return true
//					} else {
//						return false
//					}
//				}
//			}
//		}
		if lhs.totalMil > rhs.totalMil {
			return true
		} else {
			return false
		}
		
		
	}
	
	static func < (lhs: TimeSplit, rhs: TimeSplit) -> Bool {
//		if lhs.hour < rhs.hour {
//			return true
//		} else {
//			if lhs.min < rhs.min {
//				return true
//			} else {
//				if lhs.sec < rhs.sec {
//					return true
//				} else {
//					if lhs.mil < rhs.mil {
//						return true
//					} else {
//						return false
//					}
//				}
//			}
//		}
		if lhs.TSToMil() < rhs.TSToMil() {
			return true
		} else {
			return false
		}
	}
	
	
	
	//MARK - Arithmetic Stuff
	
	static func + (lhs: TimeSplit, rhs: TimeSplit) -> TimeSplit {
		let tsMil = lhs.totalMil + rhs.totalMil
		var newTimeSplit = TimeSplit(mil:tsMil)
//		newTimeSplit.hour = lhs.hour + rhs.hour
//		newTimeSplit.min = lhs.min + rhs.min
//		newTimeSplit.sec = lhs.sec + rhs.sec
//		newTimeSplit.mil = lhs.mil + rhs.mil
		
		
		
		return newTimeSplit
	}
	static func - (lhs: TimeSplit, rhs: TimeSplit) -> TimeSplit {
		let tsMil = lhs.totalMil - rhs.totalMil
		var newTimeSplit = TimeSplit(mil:tsMil)
//		if lhs.hour > rhs.hour {
//			newTimeSplit.hour = lhs.hour - rhs.hour
//		} else {
//			newTimeSplit.hour = rhs.hour - lhs.hour
//		}
//		if lhs.min > rhs.min {
//			newTimeSplit.min = lhs.min - rhs.min
//		} else {
//			newTimeSplit.min = rhs.min - lhs.min
//		}
//		if lhs.sec > rhs.sec {
//			newTimeSplit.sec = lhs.sec - rhs.sec
//		} else {
//			newTimeSplit.sec = rhs.sec - lhs.sec
//		}
//		if lhs.mil > rhs.mil {
//			newTimeSplit.mil = lhs.mil - rhs.mil
//		} else {
//			newTimeSplit.mil = rhs.mil - lhs.mil
//		}
		
		
		return newTimeSplit
	}
	
	func TSToMil() -> Int {
//		let secToMil = self.sec * 1000
//		let minToMil = self.min * 60000
//		let hourToMil = self.hour * 3600000
//		let newMil = self.mil + secToMil + minToMil + hourToMil
		
		return totalMil
		
	}
	
	convenience init (seconds: Double) {
//		init(mi)
		let mil = Int(seconds * 1000)
		self.init(mil: mil)
	}
}
