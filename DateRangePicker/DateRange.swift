//
//  DateRange.swift
//  DateRangePicker
//
//  Created by Daniel Alm on 07.11.15.
//  Copyright © 2015 Daniel Alm. All rights reserved.
//

import Foundation

public enum DateRange: Equatable {
	case custom(Date, Date)
	case pastDays(Int)
	// Spans the given calendar unit around the current date, adjusted by unit * first argument.
	// E.g. .CalendarUnit(0, .Quarter) means this quarter, .CalendarUnit(-1, .Quarter) last quarter.
	case calendarUnit(Int, NSCalendar.Unit)
	
	// MARK: - Core properties
	public var startDate: Date {
		switch(self) {
		case .custom(let startDate, _):
			return startDate.drp_beginningOfCalendarUnit(unit: .day)!
		case .pastDays(let pastDays):
			return Date().drp_addCalendarUnits(count: -pastDays, .day)!.drp_beginningOfCalendarUnit(unit: .day)!
		case .calendarUnit(let offset, let unit):
			return Date().drp_addCalendarUnits(count: offset, unit)!.drp_beginningOfCalendarUnit(unit: unit)!
		}
	}
	
	public var endDate: Date {
		switch(self) {
		case .custom(_, let endDate):
			return endDate.drp_endOfCalendarUnit(unit: .day)!
		case .pastDays(_):
			return Date().drp_endOfCalendarUnit(unit: .day)!
		case .calendarUnit(let offset, let unit):
			return Date().drp_addCalendarUnits(count: offset, unit)!.drp_endOfCalendarUnit(unit: unit)!
		}
	}
	
	// MARK: - Display-related properties and methods
	
	// Returns a title for this date range, suitable for use in e.g. a menu.
	// Returns just "Custom" for custom ranges.
	// Note: Some cases of CalendarUnit are not yet supported.
	public var title: String? {
		switch self {
		case .custom:
			return NSLocalizedString("Custom", bundle: getBundle(), comment: "Title for a custom date range.")
		case .pastDays(let pastDays):
			return String(format: NSLocalizedString(
				"Past %d Days", bundle: getBundle(), comment: "Title for a date range spanning the past %d days."),
				pastDays)
		case .calendarUnit(let offset, let unit):
			if offset == -1 && unit == .day {
				return NSLocalizedString("Yesterday", bundle: getBundle(), comment: "Date Range title for the previous day.")
			}
			
			if offset != 0 { return nil } // Not yet supported/needed.
			
			switch unit {
				// Seems like OptionSetTypes do not support enum-style case .WeekOfYear: (yet?)...
			case _ where unit == .day: return NSLocalizedString("Today", bundle: getBundle(), comment: "Date Range title for the current day.")
			case _ where unit == .weekOfYear: return NSLocalizedString("This Week", bundle: getBundle(), comment: "Date Range title for this week.")
			case _ where unit == .month: return NSLocalizedString("This Month", bundle: getBundle(), comment: "Date Range title for this month.")
			case _ where unit == .quarter: return NSLocalizedString("This Quarter", bundle: getBundle(), comment: "Date Range title for this quarter.")
			case _ where unit == .year: return NSLocalizedString("This Year", bundle: getBundle(), comment: "Date Range title for this year.")
			default: return nil // Not yet supported/needed.
			}
		}
	}
	
	// Returns a human-readable description of this date range.
	// If no "pretty" description (e.g. "Past 7 Days", "This Week", "October 2015") is available,
	// returns either a single date (if startDate.day == endDate.day) or a date range in the form of
	// "Formatted Start Date - Formatted End Date" (e.g. "05.10.15 - 10.03.15").
	public func dateRangeDescription(_ dateFormatter: DateFormatter) -> String {
		switch self {
		case .custom: break
		case .calendarUnit(let offset, let unit) where unit == .month && offset != 0:
			// Special case: A month, but not the current one. E.g. "October 2015".
			let monthDayFormat = DateFormatter.dateFormat(fromTemplate: "MMMM y", options:0, locale: Locale.current)
			let fullMonthDateFormatter = DateFormatter()
			fullMonthDateFormatter.timeStyle = .none
			fullMonthDateFormatter.dateFormat = monthDayFormat
			return fullMonthDateFormatter.string(from: endDate as Date)
		case .pastDays: fallthrough
		case .calendarUnit: if let title = title { return title }
		}
		if startDate.drp_beginningOfCalendarUnit(unit: .day) == endDate.drp_beginningOfCalendarUnit(unit: .day) {
			return dateFormatter.string(from: endDate as Date)
		}
		return "\(dateFormatter.string(from: startDate as Date)) - \(dateFormatter.string(from: endDate as Date))"
	}
	
	// MARK: - Obtaining related ranges
	public func previous() -> DateRange {
		return moveBy(-1)
	}
	
	public func next() -> DateRange {
		return moveBy(1)
	}
	
	public func moveBy(_ steps: Int) -> DateRange {
		switch self {
		case .custom, .pastDays:
			// Add one to the distance between start and end date so that for steps = 1, the date ranges do not overlap.
			let dayDifference = endDate.drp_daysSince(since: startDate as NSDate) + 1
			return .custom(startDate.drp_addCalendarUnits(count: dayDifference * steps, .day)!, endDate.drp_addCalendarUnits(count: dayDifference * steps, .day)!)
		case .calendarUnit(let offset, let unit):
			return .calendarUnit(offset + steps, unit)
		}
	}
	
	public func restrictToDates(_ minDate: NSDate?, _ maxDate: NSDate?) -> DateRange {
		var adjustedStartDate = startDate
		var adjustedEndDate = endDate
		if let minDate = minDate?.drp_beginningOfCalendarUnit(unit: .day) {
			adjustedStartDate = minDate.laterDate(adjustedStartDate)
			adjustedEndDate = minDate.laterDate(adjustedEndDate)
		}
		if let maxDate = maxDate?.drp_endOfCalendarUnit(unit: .day) {
			adjustedStartDate = maxDate.earlierDate(adjustedStartDate)
			adjustedEndDate = maxDate.earlierDate(adjustedEndDate)
		}
		if startDate != adjustedStartDate || endDate != adjustedEndDate {
			return .custom(adjustedStartDate as Date, adjustedEndDate as Date)
		}
		
		return self
	}
	
	// Ugly workaround for serialization because enums can't support NSCoding.
	public func toData() -> Data {
		let data = NSMutableData()
		let archiver = NSKeyedArchiver(forWritingWith: data)
		switch self {
		case .custom(let startDate, let endDate):
			archiver.encode("Custom", forKey: "case")
			archiver.encode(startDate, forKey: "startDate")
			archiver.encode(endDate, forKey: "endDate")
		case .pastDays(let pastDays):
			archiver.encode("PastDays", forKey: "case")
			archiver.encode(pastDays, forKey: "pastDays")
		case .calendarUnit(let offset, let unit):
			archiver.encode("CalendarUnit", forKey: "case")
			archiver.encode(offset, forKey: "offset")
			archiver.encode(Int(unit.rawValue), forKey: "unit")
		}
		archiver.finishEncoding()
		return data as Data
	}
	
	public static func fromData(_ data: Data) -> DateRange? {
		let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
		guard let caseName = unarchiver.decodeObject(forKey: "case") as? String else { return nil }
		switch caseName {
		case "Custom":
			guard let startDate = unarchiver.decodeObject(forKey: "startDate") as? Date else { return nil }
			guard let endDate = unarchiver.decodeObject(forKey: "endDate") as? Date else { return nil }
			return custom(startDate, endDate)
		case "PastDays":
			if !unarchiver.containsValue(forKey: "pastDays") { return nil }
			return pastDays(unarchiver.decodeInteger(forKey: "pastDays"))
		case "CalendarUnit":
			if !unarchiver.containsValue(forKey: "offset") { return nil }
			if !unarchiver.containsValue(forKey: "unit") { return nil }
			return calendarUnit(unarchiver.decodeInteger(forKey: "offset"), NSCalendar.Unit(rawValue: UInt(unarchiver.decodeInteger(forKey: "unit"))))
		default:
			return nil
		}
	}
}

public func ==(lhs: DateRange, rhs: DateRange) -> Bool {
	switch (lhs, rhs) {
	case (.custom, .custom):
		return lhs.startDate == rhs.startDate && lhs.endDate == rhs.endDate
	case (.pastDays(let ld), .pastDays(let rd)):
		return ld == rd
	case (.calendarUnit(let lo, let lu), .calendarUnit(let ro, let ru)):
		return lo == ro && lu == ru
	default:
		return false
	}
}
