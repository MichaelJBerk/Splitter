//
//  TimeSplit.swift
//  Splitter
//
//  Created by Michael Berk on 12/22/19.
//  Copyright © 2019 Michael Berk. All rights reserved.
//

import Foundation
import Cocoa

class TimeSplit: NSCopying, Comparable {
	
//	var milHundreth = 0
//	var mil = 0
//	var sec = 0
//	var min = 0
//	var hour = 0
	var paused = false
	var privateMil = 0
	
	init( mil:Int, sec:Int, min:Int, hour:Int) {
//		self.mil = mil
//		self.sec = sec
//		self.min = min
//		self.hour = hour
		privateMil = 0
		privateMil = privateMil + mil
		privateMil = privateMil + (sec * 1000)
		privateMil = privateMil + (min * 60000)
		privateMil = privateMil + (hour * 3600000)
		
//		self.milHundreth = 0
	}
	
	
	/// Initalizes the TimeSplit
	/// - Parameter mil: Time of the `TimeSplit`, in milliseconds. This is useful for importing from some formats, such as Splits.io
	init (mil: Int) {
		self.privateMil = mil
		//Get the total hours
		//TODO: round down
//		self.hour = mil/3600000
		//Take the remainder, and get the minutes from that, and so on
//		self.min = (mil % 3600000) / 60000
//		self.sec = (((mil % 3600000) % 60000) / 100)/10
//		self.mil = (((mil % 3600000) % 60000) % 1000)/10
		
	}
	
	
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
			
			privateMil = 0
			privateMil = privateMil + mil
			privateMil = privateMil + (sec * 1000)
			privateMil = privateMil + (min * 60000)
			privateMil = privateMil + (hour * 3600000)
			
			
		} else {
//			self.mil = 0
//			self.sec = 0
//			self.min = 0
//			self.hour = 0
			self.privateMil = 0
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
		self.privateMil = 0
	}
	@objc func updateMil() {
		if !paused {
			privateMil = privateMil + 1
			
//			if mil == 99 {
//				mil = 0
//				if sec == 59 {
//					sec = 0
//					if min == 59 {
//						min = 0
//						if hour == 23 {
//							hour = 0
//						} else {
//							hour = hour + 1
//						}
//					} else {
//						min = min + 1
//					}
//				} else {
//					sec = sec + 1
//				}
//			} else {
//				mil = mil + 1
//			}
			
		}
	}
	
	/**
	Returns time of the`TimeSplit` as a `String`.
	**/
	var timeString: String {
		return privateMil.toFormatedTimeString()
//			return String(format: "%.2d:%.2d:%.2d.%.02d", hour, min, sec, mil)
	}
	
	///Returns the `TimeSplit` as a `String`, but only includes the first significant field
	var shortTimeString: String {
//		if hour == 0 {
//			if min == 0 {
//				return String(format: "%.2d.%.2d", sec, mil)
//			}
//			return String(format: "%.2d:%.2d.%.2d", min, sec, mil)
//		}
//		return String(format: "%.2d:%.2d:%.2d.%.2d", hour, min, sec, mil)
		return privateMil.toShortFormattedTimeString()
	}
	
	///Returns a `shortTimeString`, but is rounded to the tenths instead of hundredths
	var shortTimeStringTenths: String {
//		let milRounded = Int((Double(mil)/10.00).rounded())
//		if hour == 0 {
//			if min == 0 {
//
//				return String(format: "%.2d.%.1d", sec, milRounded)
//			}
//			return String(format: "%.2d:%.2d.%.1d", min, sec, milRounded)
//		}
//		return String(format: "%.2d:%.2d:%.2d.%.1d", hour, min, sec, milRounded)
		return privateMil.toShortFormattedTimeStringTenths()
	}
	
	
	func frozenTimeSplit() -> TimeSplit {
//		let newTimeSplit = TimeSplit(mil: self.mil, sec: self.sec, min: self.min, hour: self.hour)
		let newTimeSplit = TimeSplit(mil: self.privateMil)
		return newTimeSplit
	}
	
	func copy(with zone: NSZone? = nil) -> Any {
		return TimeSplit(mil: privateMil)
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
		if lhs.privateMil > rhs.privateMil {
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
		let tsMil = lhs.privateMil + rhs.privateMil
		var newTimeSplit = TimeSplit(mil:tsMil)
//		newTimeSplit.hour = lhs.hour + rhs.hour
//		newTimeSplit.min = lhs.min + rhs.min
//		newTimeSplit.sec = lhs.sec + rhs.sec
//		newTimeSplit.mil = lhs.mil + rhs.mil
		
		
		
		return newTimeSplit
	}
	static func - (lhs: TimeSplit, rhs: TimeSplit) -> TimeSplit {
		let tsMil = lhs.privateMil - rhs.privateMil
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
		
		return privateMil
		
	}
	
	convenience init (seconds: Double) {
//		init(mi)
		let mil = Int(seconds * 1000)
		self.init(mil: mil)
	}
}

extension Int {
	func toFormatedTimeString() -> String{
		let milSec = self % 100
		let sec = (self / 100) % 60
		let min = (self / 6000) % 60
		let hour = (self / 3600000) % 60
		
		let formatString = String(format: "%02d:%02d:%02d.%02d", abs(hour), abs(min), abs(sec), abs(milSec))
	  
	   return formatString
   }
	func toShortFormattedTimeString() -> String {
		let milSec = self % 100
		let sec = (self / 100) % 60
		let min = (self / 6000) % 60
		let hour = (self / 3600000) % 60
		
		var formatString = String(format: "%02d:%02d:%02d.%02d",abs(hour), abs(min), abs(sec), abs(milSec))
		if hour == 0 {
			if min == 0 {
				formatString = String(format: "%02d.%02d", abs(sec), abs(milSec))
			} else {
				formatString = String(format: "%02:%02d.%02d", abs(min), abs(sec), abs(milSec))
			}
		}
		
		
		
		return formatString
	}
	func toShortFormattedTimeStringTenths() -> String {
		
		let milSec = self % 100
		let milRounded = Int((Double(milSec)/10.00).rounded())
		let sec = (self / 100) % 60
		let min = (self / 6000) % 60
		let hour = (self / 3600000) % 60
		
		var formatString = String(format: "%02d:%02d:%02d.%01d",abs(hour), abs(min), abs(sec), abs(milRounded))
		if hour == 0 {
			if min == 0 {
				formatString = String(format: "%02d.%01d", abs(sec), abs(milRounded))
			} else {
				formatString = String(format: "%02d:%02d.%01d", abs(min), abs(sec), abs(milRounded))
			}
		}
		return formatString
	}
}
