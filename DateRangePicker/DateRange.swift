//
//  DateRange.swift
//  DateRangePicker
//
//  Created by Daniel Alm on 07.11.15.
//  Copyright © 2015 Daniel Alm. All rights reserved.
//

import Foundation

public enum DateRange: Equatable {
	case Custom(NSDate, NSDate)
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
	
	var startDate: NSDate? {
		switch(self) {
		case Custom(let startDate, _):
			return startDate
		case None:
			return nil
		case PastDays(let pastDays):
			return NSDate().drp_addDays(-pastDays)
		case CurrentCalendarUnit(let calendarUnit):
			return NSDate().drp_beginningOfCalendarUnit(calendarUnit)
		}
	}
	
	var endDate: NSDate? {
		switch(self) {
		case Custom(_, let endDate):
			return endDate
		case None:
			return nil
		case PastDays(_):
			return NSDate()
		case CurrentCalendarUnit(let calendarUnit):
			return NSDate().drp_endOfCalendarUnit(calendarUnit)
		}
	}
}

public func ==(lhs: DateRange, rhs: DateRange) -> Bool {
	switch (lhs, rhs) {
	case (.Custom(let ls, let le), .Custom(let rs, let re)):
		return ls == rs && le == re
	case (.PastDays(let ld), .PastDays(let rd)):
		return ld == rd
	case (.CurrentCalendarUnit(let lu), .CurrentCalendarUnit(let ru)):
		return lu == ru
	case (.None, .None):
		return true
	default:
		return false
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
