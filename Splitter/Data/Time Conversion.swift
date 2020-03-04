//
//  Time Conversion.swift
//  Splitter
//
//  Created by Michael Berk on 3/3/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Foundation

func dateToRFC339String(date: Date) -> String {
//	var now = NSDate()
	var formatter = DateFormatter()
	formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
	formatter.timeZone = TimeZone(secondsFromGMT: 0)
	return formatter.string(from: date)
}

func convertRFC3339DateTimeToString(rfc3339DateTime: String!) -> String {
     
	let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
     
	let date = dateFormatter.date(from: rfc3339DateTime)
    var userVisibleDateTimeString: String!
	var userVisibleDateFormatter = DateFormatter()
	userVisibleDateFormatter.dateStyle = DateFormatter.Style.medium
	userVisibleDateFormatter.timeStyle = DateFormatter.Style.short
	userVisibleDateTimeString = userVisibleDateFormatter.string(from: date!)
     
    return userVisibleDateTimeString
}
