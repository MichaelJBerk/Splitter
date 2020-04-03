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
	var totalMil = 0
	
	//MARK: - Initializers
	
	/// Creates a `TimeSplit` with the given duration
	/// - Parameters:
	///   - mil: milliseconds of the `TimeSplit`
	///   - sec: seconds of the `TimeSplit`
	///   - min: minutes of the `TimeSplit`
	///   - hour: hours of the `TimeSplit`
	init( mil:Int, sec:Int, min:Int, hour:Int) {
		totalMil = 0
		totalMil = totalMil + mil
		totalMil = totalMil + (sec * 100)
		totalMil = totalMil + (min * 60000)
		totalMil = totalMil + (hour * 3600000)
	}
	
	
	/// Initalizes the TimeSplit
	/// - Parameter mil: Time of the `TimeSplit`, in milliseconds.
	init (mil: Int) {
		self.totalMil = mil
	}
	
	/// Initalizes the time split from using string in the format "00:00:00.00" with hours, minutes, seconds, and milliseconds.
	/// - Parameter timeString: String of a time value in the format "00:00:00.00" for hours, minutes, seconds, and milliseconds
	init(timeString: String) {
		var hourMilSec = timeString.split(separator: ":", maxSplits: 3, omittingEmptySubsequences: false)
		
		if hourMilSec.count == 2 {
			let newTimeString = "00:" + timeString;
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
	convenience override init () {
		self.init(mil: 0)
	}
	
	/// Creates a TimeSplit set to the number of seconds given
	/// - Parameter seconds: initial duration of the `TimeSplit`
	convenience init (seconds: Double) {
		let mil = Int(seconds * 1000)
		self.init(mil: mil)
	}
	
	//MARK: - Time Values
	/// Returns the current millisecond of the `TimeSplit`
	var mil: Int {
		return totalMil % 100
	}
	/// Returns the current second of the `TimeSplit`
	var sec: Int {
		return Int(totalMil / 100) % 60
	}
	
	/// Returns the current minute of the `TimeSplit`
	var min: Int {
		return Int(totalMil/6000) % 60

	}
	///Returns the current hour of the `TimeSplit`
	var hour: Int {
		return totalMil / 360000
	}
	
	func reset() {
		self.totalMil = 0
	}
	
	///The function that updates the TimeSplit every millisecond
	@objc func updateMil() {
		if !paused {
			totalMil = totalMil + 1
		}
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
		let newTimeSplit = TimeSplit(mil: self.totalMil)
		return newTimeSplit
	}
	
	func copy(with zone: NSZone? = nil) -> Any {
		return TimeSplit(mil: totalMil)
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
		if lhs.totalMil > rhs.totalMil {
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
		let tsMil = lhs.totalMil + rhs.totalMil
		let newTimeSplit = TimeSplit(mil:tsMil)
		return newTimeSplit
	}
	static func - (lhs: TimeSplit, rhs: TimeSplit) -> TimeSplit {
		let tsMil = lhs.totalMil - rhs.totalMil
		let newTimeSplit = TimeSplit(mil:tsMil)
		return newTimeSplit
	}
	

	
	
}
