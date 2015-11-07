//
//  DateRange.swift
//  DateRangePicker
//
//  Created by Daniel Alm on 07.11.15.
//  Copyright © 2015 Daniel Alm. All rights reserved.
//

import Foundation

public enum DateRange {
	case Custom
	case PastDays(Int)
	case CurrentCalendarUnit(NSCalendarUnit)
	case None
	
	var title: String {
		switch (self) {
		case Custom:
			return NSLocalizedString("Custom", comment: "Menu item title to select a custom date range.")
		case PastDays(let pastDays):
			return String(format: NSLocalizedString(
				"Past %d days", comment: "Menu item title to select a date range spanning the past %d days."),
				pastDays)
		case CurrentCalendarUnit(let calendarUnit):
			return String(format: NSLocalizedString(
				"This %@", comment: "Menu item title to select a date range based on a calendar unit."),
				calendarUnit.drp_Name ?? "")
		case None:
			return ""
		}
	}
}

extension NSCalendarUnit: Hashable {
	public var hashValue: Int {
		get {
			return Int(rawValue)
		}
	}
}

public extension NSCalendarUnit {
	static let drp_Names: [NSCalendarUnit:String] = [
		.Day: NSLocalizedString("Day", comment: "Calendar Unit: Day."),
		.WeekOfYear: NSLocalizedString("Week", comment: "Calendar Unit: Week of Year."),
		.Month: NSLocalizedString("Month", comment: "Calendar Unit: Month."),
		.Quarter: NSLocalizedString("Quarter", comment: "Calendar Unit: Quarter."),
		.Year: NSLocalizedString("Year", comment: "Calendar Unit: Year.")
	]
	
	var drp_Name: String? {
		get {
			return NSCalendarUnit.drp_Names[self]
		}
	}
}
