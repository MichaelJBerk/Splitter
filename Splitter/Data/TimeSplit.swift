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
class TimeSplit: NSObject, NSCopying, Comparable {
	
	///Whether or not the `TimeSplit` is paused
	var paused = false
	///Total MS elapsed from start of TimeSplit
	var totalMil: Int {
		get {
			Int(totalSec * 1000)
		}
	}
	
	var totalSec: Double = 0
	
	//MARK: - Initializers
	
	/// Creates a `TimeSplit` with the given duration
	/// - Parameters:
	///   - mil: milliseconds of the `TimeSplit`
	///   - sec: seconds of the `TimeSplit`
	///   - min: minutes of the `TimeSplit`
	///   - hour: hours of the `TimeSplit`
	convenience init( mil:Int, sec:Int, min:Int, hour:Int) {

		let str = "\(hour):\(min):\(sec).\(mil)"
		self.init(timeString: str)
	}
	
	
	/// Initalizes the TimeSplit
	/// - Parameter mil: Time of the `TimeSplit`, in milliseconds.
	init (mil: Int) {
		self.totalSec = Double(mil / 1000)
	}
	
	/// Initalizes the time split from using string in the format "00:00:00.00" with hours, minutes, seconds, and milliseconds.
	/// - Parameter timeString: String of a time value in the format "00:00:00.00" for hours, minutes, seconds, and milliseconds
	init(timeString: String) {
//		var hourMilSec = timeString.split(separator: ":", maxSplits: 3, omittingEmptySubsequences: false)
//
//		if hourMilSec.count == 2 {
//			let newTimeString = "00:" + timeString;
//			hourMilSec = newTimeString.split(separator: ":", maxSplits: 3, omittingEmptySubsequences: false)
//		}
//		let secSplit = hourMilSec.last?.split(separator: ".")
//
//		hourMilSec.removeLast()
//		hourMilSec.append(contentsOf: secSplit!)
//
//		if hourMilSec.count == 3 {
//			hourMilSec.append("00")
//		}
//		let finalSplit = hourMilSec
//		if hourMilSec.count >= 3 {
//			let mil = Int(String(finalSplit[3])) ?? 0
//			let sec = Int(String(finalSplit[2])) ?? 0
//			let min = Int(String(finalSplit[1])) ?? 0
//			let hour = Int(String(finalSplit[0])) ?? 0
//
//			totalSec = 0
//			totalSec = totalSec + Double(mil)
//			totalSec = totalSec + (Double(sec) * 100)
//			totalSec = totalSec + (Double(min) * 6000)
//			totalSec = totalSec + (Double(hour) * 360000)
//
//
//		} else {
//			self.totalSec = 0
//		}
		let time = LiveSplitCore.TimeSpan.parse(timeString)
		self.totalSec = time!.totalSeconds()
		
	}
	
	///Creates an "empty" TimeSplit, with the time set to 0
	convenience override init () {
		self.init(seconds: 0)
	}
	
	/// Creates a TimeSplit set to the number of seconds given
	/// - Parameter seconds: initial duration of the `TimeSplit`
	init (seconds: Double) {
//		let mil = Int(seconds * 1000)
//		self.init(mil: mil)
		totalSec = seconds
	}
	
	//MARK: - Time Values
	/// Returns the current millisecond of the `TimeSplit`
	
	var mil: Int {
		let dec = totalSec.truncatingRemainder(dividingBy: 1)
		let dtoi = Int((dec * 100).rounded())
		
		return dtoi//Int(String(decSplit)) ?? 0
		
	}
	/// Returns the current second of the `TimeSplit`
	var sec: Int {
		//This needs to be the remainder of `totalSec/60`, since otherwise the seconds would go past 60
		return Int(totalSec) % 60
	}
	
	/// Returns the current minute of the `TimeSplit`
	var min: Int {
//		return Int(totalSec. / 60)
		return (Int(totalSec) / 60) % 60//.remainder(dividingBy: 60))
	}
	///Returns the current hour of the `TimeSplit`
	var hour: Int {
		return (Int(totalSec) / 60) / 60
	}
	
	func reset() {
		self.totalSec = 0
	}
	
	///The function that updates the TimeSplit every millisecond
	@objc func updateMil() {
		if !paused {
//			totalMil = totalMil + 1
		}
	}
	
	@objc func updateSec(sec: Double) {
//		self.totalMil = Int(sec * 1000)
		totalSec = sec
	}
	//MARK: - Strings
	
	override var debugDescription: String {
		return self.timeString
	}
	override var description: String {
		return self.timeString
	}
	
	/**
	Returns time of the`TimeSplit` as a `String`.
	**/
	var timeString: String {
		
		return String(format: "%.2d:%.2d:%.2d.%.02d", abs(hour), abs(min), abs(sec), abs(mil))
	}
	
	///Returns the `TimeSplit` as a `String`, but only includes the first significant field
	var shortTimeString: String {
		let m = self.mil
		if hour == 0 {
			if min == 0 {
				return String(format: "%.2d.%.2d", abs(sec), abs(mil))
			}
			return String(format: "%.2d:%.2d.%.2d", abs(min), abs(sec), abs(mil))
		}
		return String(format: "%.2d:%.2d:%.2d.%.2d", abs(hour), abs(min), abs(sec), abs(mil))
	}
	
	///Returns a `shortTimeString`, but is rounded to the tenths instead of hundredths
	var shortTimeStringTenths: String {
		
		let m = self.mil
		let milRounded = Int((Double(mil)/10.00).rounded())
		if hour == 0 {
			if min == 0 {
				return String(format: "%.2d.%.1d", abs(sec), abs(milRounded))
			}
			return String(format: "%.2d:%.2d.%.1d", abs(min), abs(sec), abs(milRounded))
		}
		return String(format: "%.2d:%.2d:%.2d.%.1d", abs(hour), abs(min), abs(sec), abs(milRounded))
	}
	
	//MARK: - Conversion/Copying
	
	func TSToMil() -> Int {
		return totalMil
	}
	
	func frozenTimeSplit() -> TimeSplit {
		let newTimeSplit = TimeSplit(seconds: self.totalSec)
		return newTimeSplit
	}
	
	func copy(with zone: NSZone? = nil) -> Any {
		return TimeSplit(seconds: totalSec)
	}
	
	func tsCopy() -> TimeSplit {
		return self.copy() as! TimeSplit
	}
	
	//MARK: - Comparing TimeSplits
	static func == (lhs: TimeSplit, rhs: TimeSplit) -> Bool {
		if lhs.timeString == rhs.timeString {
			return true
		} else {
			return false
		}
		
	}
	
	static func > (lhs: TimeSplit, rhs: TimeSplit) -> Bool {
		if lhs.totalSec > rhs.totalSec {
			return true
		} else {
			return false
		}
		
		
	}
	
	static func < (lhs: TimeSplit, rhs: TimeSplit) -> Bool {
		if lhs.TSToMil() < rhs.TSToMil() {
			return true
		} else {
			return false
		}
	}
	
	
	
	//MARK: - Add/Subtract Splits
	static func + (lhs: TimeSplit, rhs: TimeSplit) -> TimeSplit {
		let tsSec = lhs.totalSec + rhs.totalSec
		let newTimeSplit = TimeSplit(seconds: tsSec)
		return newTimeSplit
	}
	static func - (lhs: TimeSplit, rhs: TimeSplit) -> TimeSplit {
		let tsSec = lhs.totalSec - rhs.totalSec
		let newTimeSplit = TimeSplit(seconds: tsSec)
		return newTimeSplit
	}
	

	
	
}
