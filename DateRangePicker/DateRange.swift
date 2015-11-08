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
	// Spans the given calendar unit around the current date, adjusted by unit * first argument.
	// E.g. .CalendarUnit(0, .Quarter) means this quarter, .CalendarUnit(-1, .Quarter) last quarter.
	case CalendarUnit(Int, NSCalendarUnit)
	case None
	
	public var title: String {
		switch (self) {
		case Custom:
			return NSLocalizedString("Custom", comment: "Title for a custom date range.")
		case PastDays(let pastDays):
			return String(format: NSLocalizedString(
				"Past %d days", comment: "Title for a date range spanning the past %d days."),
				pastDays)
		case CalendarUnit(let offset, let unit):
			switch (offset) {
			case _ where offset > 0:
				// TODO: These currently do not use proper plural forms for the unit.
				return String(format: NSLocalizedString(
					"%d %@ in the future", comment: "Title for a future date range based on a calendar unit."),
					offset, unit.drp_Name ?? "")
			case _ where offset < 0:
				return String(format: NSLocalizedString(
					"%d %@ ago", comment: "Title for a past date range based on a calendar unit."),
					-offset, unit.drp_Name ?? "")
			default: // offset == 0
				return String(format: NSLocalizedString(
					"This %@", comment: "Title for a current date range based on a calendar unit."),
					unit.drp_Name ?? "")
			}
		case None:
			return NSLocalizedString("None", comment: "Title for a nonexistent date range.")
		}
	}
	
	public var startDate: NSDate? {
		switch(self) {
		case Custom(let startDate, _):
			return startDate.drp_beginningOfCalendarUnit(.Day)
		case PastDays(let pastDays):
			return NSDate().drp_addCalendarUnits(-pastDays, .Day)?.drp_beginningOfCalendarUnit(.Day)
		case CalendarUnit(let offset, let unit):
			return NSDate().drp_addCalendarUnits(offset, unit)?.drp_beginningOfCalendarUnit(unit)
		case None:
			return nil
		}
	}
	
	public var endDate: NSDate? {
		switch(self) {
		case Custom(_, let endDate):
			return endDate.drp_endOfCalendarUnit(.Day)
		case PastDays(_):
			return NSDate().drp_endOfCalendarUnit(.Day)
		case CalendarUnit(let offset, let unit):
			return NSDate().drp_addCalendarUnits(offset, unit)?.drp_endOfCalendarUnit(unit)
		case None:
			return nil
		}
	}
	
	public func previous() -> DateRange {
		return moveBy(-1)
	}
	
	public func next() -> DateRange {
		return moveBy(1)
	}
	
	public func moveBy(steps: Int) -> DateRange {
		switch (self) {
		case Custom, PastDays:
			guard let startDate = startDate else { return None }
			guard let endDate = endDate else { return None }
			// Add one to the distance between start and end date so that for steps = 1, the date ranges do not overlap.
			let dayDifference = endDate.drp_daysSince(startDate) + 1
			return Custom(startDate.drp_addCalendarUnits(dayDifference * steps, .Day)!, endDate.drp_addCalendarUnits(dayDifference * steps, .Day)!)
		case CalendarUnit(let offset, let unit):
			return CalendarUnit(offset + steps, unit)
		case None:
			return self
		}
	}
	
	// Ugly workaround for serialization because enums can't support NSCoding.
	public func toData() -> NSData {
		let data = NSMutableData()
		let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
		switch (self) {
		case Custom(let startDate, let endDate):
			archiver.encodeObject("Custom", forKey: "case")
			archiver.encodeObject(startDate, forKey: "startDate")
			archiver.encodeObject(endDate, forKey: "endDate")
		case PastDays(let pastDays):
			archiver.encodeObject("PastDays", forKey: "case")
			archiver.encodeInteger(pastDays, forKey: "pastDays")
		case CalendarUnit(let offset, let unit):
			archiver.encodeObject("CalendarUnit", forKey: "case")
			archiver.encodeInteger(offset, forKey: "offset")
			archiver.encodeInteger(Int(unit.rawValue), forKey: "unit")
		case None:
			archiver.encodeObject("None", forKey: "case")
		}
		archiver.finishEncoding()
		return data
	}
	
	public static func fromData(data: NSData) -> DateRange? {
		let unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
		guard let caseName = unarchiver.decodeObjectForKey("case") as? String else { return nil }
		switch caseName {
		case "Custom":
			guard let startDate = unarchiver.decodeObjectForKey("startDate") as? NSDate else { return nil }
			guard let endDate = unarchiver.decodeObjectForKey("endDate") as? NSDate else { return nil }
			return Custom(startDate, endDate)
		case "PastDays":
			if !unarchiver.containsValueForKey("pastDays") { return nil }
			return PastDays(unarchiver.decodeIntegerForKey("pastDays"))
		case "CalendarUnit":
			if !unarchiver.containsValueForKey("offset") { return nil }
			if !unarchiver.containsValueForKey("unit") { return nil }
			return CalendarUnit(unarchiver.decodeIntegerForKey("offset"), NSCalendarUnit(rawValue: UInt(unarchiver.decodeIntegerForKey("unit"))))
		case "None":
			return None
		default:
			return nil
		}
	}
	
	public func restrictToDates(minDate: NSDate?, _ maxDate: NSDate?) -> DateRange {
		guard let startDate = startDate else { return None }
		guard let endDate = endDate else { return None }
		
		var adjustedStartDate = startDate
		var adjustedEndDate = endDate
		if let minDate = minDate?.drp_beginningOfCalendarUnit(.Day) {
			adjustedStartDate = minDate.laterDate(adjustedStartDate)
			adjustedEndDate = minDate.laterDate(adjustedEndDate)
		}
		if let maxDate = maxDate?.drp_endOfCalendarUnit(.Day) {
			adjustedStartDate = maxDate.earlierDate(adjustedStartDate)
			adjustedEndDate = maxDate.earlierDate(adjustedEndDate)
		}
		if startDate != adjustedStartDate || endDate != adjustedEndDate {
			return Custom(adjustedStartDate, adjustedEndDate)
		}
		
		return self
	}
}

public func ==(lhs: DateRange, rhs: DateRange) -> Bool {
	switch (lhs, rhs) {
	case (.Custom, .Custom):
		return lhs.startDate == rhs.startDate && lhs.endDate == rhs.endDate
	case (.PastDays(let ld), .PastDays(let rd)):
		return ld == rd
	case (.CalendarUnit(let lo, let lu), .CalendarUnit(let ro, let ru)):
		return lo == ro && lu == ru
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
