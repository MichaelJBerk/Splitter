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
		//This will never be invalid, since we're constructing the string in the line above so it's
		//safe to force-unwrap it
		self.init(timeString: str)!
	}
	
	
	/// Initalizes the TimeSplit
	/// - Parameter mil: Time of the `TimeSplit`, in milliseconds.
	init (mil: Int) {
		self.totalSec = Double(mil / 1000)
	}
	
	/**
	Initalizes an optional time split from using string in the format "00:00:00.00" with hours, minutes, seconds, and milliseconds.
	- Parameter timeString: String of a time value in the format "00:00:00.00" for hours, minutes, seconds, and milliseconds.
	If invalid, the initalizer will return `nil`.
	
	- Important: Since the initalizer is optional, you'll need to plan accordingly for cases where it may return nil. If you're just trying to load a split with a specific time, (i.e. 02:08:50.02), use `init( mil:Int, sec:Int, min:Int, hour:Int) ` instead.
	
	It's best to use this when parsing a string into a time split (such as text from a text field). Since it will return `nil` if the text is invalid, you can, for example, cancel the edit if the string is not a valid time, or handle it some other way.
*/
	init?(timeString: String?) {
		if let timeString = timeString,
			let time = LiveSplitCore.TimeSpan.parse(timeString) {
			self.totalSec = time.totalSeconds()
		} else {
			return nil
		}
		
	}
	
	///Creates an "empty" TimeSplit, with the time set to 0
	convenience override init () {
		self.init(seconds: 0)
	}
	
	/// Creates a TimeSplit set to the number of seconds given
	/// - Parameter seconds: initial duration of the `TimeSplit`
	init (seconds: Double) {
		totalSec = seconds
	}
	
	//MARK: - Time Values
	/// Returns the current millisecond of the `TimeSplit`
	
	var mil: Int {
		let dec = totalSec.truncatingRemainder(dividingBy: 1)
		let dtoi = Int((dec * 100).rounded())
		
		return dtoi
		
	}
	/// Returns the current second of the `TimeSplit`
	var sec: Int {
		//This needs to be the remainder of `totalSec/60`, since otherwise the seconds would go past 60
		return Int(totalSec) % 60
	}
	
	/// Returns the current minute of the `TimeSplit`
	var min: Int {
		return (Int(totalSec) / 60) % 60
	}
	///Returns the current hour of the `TimeSplit`
	var hour: Int {
		return (Int(totalSec) / 60) / 60
	}
	
	func reset() {
		self.totalSec = 0
	}
	
	///Update the total seconds of the `TimeSplit`
	@objc func updateSec(sec: Double) {
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
