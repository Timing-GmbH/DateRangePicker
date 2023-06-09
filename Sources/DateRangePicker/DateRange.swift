//
//  DateRange.swift
//  DateRangePicker
//
//  Created by Daniel Alm on 07.11.15.
//  Copyright © 2015 Daniel Alm. All rights reserved.
//

import Foundation

extension NSCalendar.Unit {
	public var drp_correspondingCalendarComponent: Calendar.Component? {
		switch self {
		case NSCalendar.Unit.era: return .era
		case NSCalendar.Unit.year: return .year
		case NSCalendar.Unit.month: return .month
		case NSCalendar.Unit.day: return .day
		case NSCalendar.Unit.hour: return .hour
		case NSCalendar.Unit.minute: return .minute
		case NSCalendar.Unit.second: return .second
		case NSCalendar.Unit.weekday: return .weekday
		case NSCalendar.Unit.weekdayOrdinal: return .weekdayOrdinal
		case NSCalendar.Unit.quarter: return .quarter
		case NSCalendar.Unit.weekOfMonth: return .weekOfMonth
		case NSCalendar.Unit.weekOfYear: return .weekOfYear
		case NSCalendar.Unit.yearForWeekOfYear: return .yearForWeekOfYear
		case NSCalendar.Unit.nanosecond: return .nanosecond
		case NSCalendar.Unit.calendar: return .calendar
		case NSCalendar.Unit.timeZone: return .timeZone
		default: return nil
		}
	}
}

extension Date {
	// TR-961: This property tries to avoid a crash when force-unwrapping `drp_settingHour(to: 0)` if there is no
	// 0:00:00, e.g. due to a weird DST switch (e.g. Iran and Brazil switch DST at 0:00).
	//! TODO(TR-961): Use this (and similar approaches) on more occasions.
	var dayStart: Date {
		if self.timeIntervalSince1970 < 0 {
			// This hopefully avoids a crash for "very old" dates.
			return self
		}
		
		for i in 0...23 {
			if let hour = self.drp_settingHour(to: i) {
				return hour
			}
		}
		globalDateErrorLogger?.logDayStartFailed(for: self, calendar: Calendar.current)
		let calendar = Calendar.current
		fatalError("error fetching dayStart for: date='\(self)' timeIntervalSince1970='\(self.timeIntervalSince1970)' calendar='\(calendar), \(calendar.identifier)' locale='\(Locale.current)' timeZone='\(calendar.timeZone)' abbreviation='\(calendar.timeZone.abbreviation() ?? "(nil)")' secondsFromGMT='\(calendar.timeZone.secondsFromGMT())' isDaylightSavingTime='\(calendar.timeZone.isDaylightSavingTime())' daylightSavingTimeOffset='\(calendar.timeZone.daylightSavingTimeOffset())' abbreviationForDate='\(calendar.timeZone.abbreviation(for: self) ?? "(nil)")' secondsFromGMTForDate='\(calendar.timeZone.secondsFromGMT(for: self))' isDaylightSavingTimeForDate='\(calendar.timeZone.isDaylightSavingTime(for: self))' daylightSavingTimeOffsetForDate='\(calendar.timeZone.daylightSavingTimeOffset(for: self))'")
	}
}

public enum DateRange: Equatable {
	case custom(Date, Date, hourShift: Int)
	case pastDays(Int, hourShift: Int)
	// Spans the given calendar unit around the current date, adjusted by unit * first argument.
	// E.g. .CalendarUnit(0, .Quarter) means this quarter, .CalendarUnit(-1, .Quarter) last quarter.
	case calendarUnit(Int, NSCalendar.Unit, hourShift: Int)
	
	// MARK: - Core properties
	public var startDate: Date {
		return getStartDate(now: Date())
	}
	
	public var endDate: Date {
		return getEndDate(now: Date())
	}
	
	public var hourShift: Int {
		get {
			switch self {
			case let .custom(_, _, hourShift): return hourShift
			case let .pastDays(_, hourShift): return hourShift
			case let .calendarUnit(_, _, hourShift): return hourShift
			}
		}
		
		set {
			switch self {
			case let .custom(startDate, endDate, _): self = .custom(startDate, endDate, hourShift: newValue)
			case let .pastDays(pastDays, _): self = .pastDays(pastDays, hourShift: newValue)
			case let .calendarUnit(offset, unit, _): self = .calendarUnit(offset, unit, hourShift: newValue)
			}
		}
	}
	
	// These functions are required for testing getStartDate(withHourShift:) and getEndDate(withHourShift:) for
	// DateRange.pastDays and DateRange.calendarUnit with a fake "now" without depending on the hour of day the test is
	// run.
	func getStartDate(now: Date) -> Date {
		switch (self) {
		case let .custom(startDate, _, _):
			// Hour shift doesn't need to be taken into account with custom ranges.
			return startDate.dayStart
		case let .pastDays(pastDays, hourShift):
			return now
				.drp_beginning(of: .day, hourShift: hourShift)?
				.drp_adding(-pastDays, component: .day)?
				.dayStart
				// This might reduce the likelihood of crashes due to trying to forcibly unwrap nil (also below).
				?? now
					.drp_adding(-pastDays, component: .day)?
					.drp_beginning(of: .day, hourShift: hourShift)?
					.dayStart
				?? now
					.drp_adding(-pastDays, component: .day)?
					.dayStart
				?? now
		case let .calendarUnit(offset, unit, hourShift):
			return now
				.drp_beginning(of: unit.drp_correspondingCalendarComponent!, hourShift: hourShift)?
				.drp_adding(offset, component: unit.drp_correspondingCalendarComponent!)?
				.dayStart
				?? now
					.drp_adding(offset, component: unit.drp_correspondingCalendarComponent!)?
					.drp_beginning(of: unit.drp_correspondingCalendarComponent!, hourShift: hourShift)?
					.dayStart
				?? now
					.drp_adding(offset, component: unit.drp_correspondingCalendarComponent!)?
					.dayStart
				?? now
		}
	}
	
	func getEndDate(now: Date) -> Date {
		switch (self) {
		case let .custom(_, endDate, _):
			// Hour shift doesn't need to be taken into account with custom ranges.
			return endDate
				.dayStart
				.drp_adding(1, component: .day)?
				.addingTimeInterval(-1)
				?? endDate
					.drp_adding(1, component: .day)?
					.dayStart
					.addingTimeInterval(-1)
				?? now
		case let .pastDays(_, hourShift):
			return now
				.drp_end(of: .day, hourShift: hourShift)?
				.dayStart
				.addingTimeInterval(-1)
				?? now
					.dayStart
					.drp_end(of: .day, hourShift: hourShift)?
					.addingTimeInterval(-1)
				?? now
		case let .calendarUnit(offset, unit, hourShift):
			return now
				.drp_end(of: unit.drp_correspondingCalendarComponent!, hourShift: hourShift)?
				.drp_adding(offset, component: unit.drp_correspondingCalendarComponent!)?
				.dayStart
				.addingTimeInterval(-1)
				?? now
					.drp_adding(offset, component: unit.drp_correspondingCalendarComponent!)?
					.drp_end(of: unit.drp_correspondingCalendarComponent!, hourShift: hourShift)?
					.dayStart
					.addingTimeInterval(-1)
				?? now
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
		case .pastDays(let pastDays, _):
			return String(format: NSLocalizedString(
				"Past %d Days", bundle: getBundle(), comment: "Title for a date range spanning the past %d days."),
			              pastDays)
		case .calendarUnit(let offset, let unit, _):
			if offset == -1 {
				switch unit {
				case .day: return NSLocalizedString("Yesterday", bundle: getBundle(), comment: "Date Range title for the previous day.")
				case .weekOfYear: return NSLocalizedString("Last Week", bundle: getBundle(), comment: "Date Range title for last week.")
				case .month: return NSLocalizedString("Last Month", bundle: getBundle(), comment: "Date Range title for last month.")
				case .quarter: return NSLocalizedString("Last Quarter", bundle: getBundle(), comment: "Date Range title for last quarter.")
				case .year: return NSLocalizedString("Last Year", bundle: getBundle(), comment: "Date Range title for last year.")
				default: break
				}
			}
			
			guard offset == 0
				else { return nil } // Not yet supported/needed.
			
			switch unit {
			case .day: return NSLocalizedString("Today", bundle: getBundle(), comment: "Date Range title for the current day.")
			case .weekOfYear: return NSLocalizedString("This Week", bundle: getBundle(), comment: "Date Range title for this week.")
			case .month: return NSLocalizedString("This Month", bundle: getBundle(), comment: "Date Range title for this month.")
			case .quarter: return NSLocalizedString("This Quarter", bundle: getBundle(), comment: "Date Range title for this quarter.")
			case .year: return NSLocalizedString("This Year", bundle: getBundle(), comment: "Date Range title for this year.")
			default: return nil // Not yet supported/needed.
			}
		}
	}
	
	// A slightly shortened variant of .title.
	public var shortTitle: String? {
		switch self {
		case .pastDays(let pastDays, _):
			return String(format: NSLocalizedString(
				"%d Days", bundle: getBundle(), comment: "Shorthand title for a date range spanning the past %d days."),
			              pastDays)
		case .calendarUnit(let offset, let unit, _):
			if offset != 0 { return self.title }
			
			switch unit {
			case .weekOfYear: return NSLocalizedString("Week", bundle: getBundle(), comment: "Date Range short title for this week.")
			case .month: return NSLocalizedString("Month", bundle: getBundle(), comment: "Date Range short title for this month.")
			case .quarter: return NSLocalizedString("Quarter", bundle: getBundle(), comment: "Date Range short title for this quarter.")
			case .year: return NSLocalizedString("Year", bundle: getBundle(), comment: "Date Range short title for this year.")
			default: return self.title
			}
		case .custom: return self.title
		}
	}
	
	// Returns a human-readable description of this date range.
	// If no "pretty" description (e.g. "Past 7 Days", "This Week", "October 2015") is available,
	// returns either a single date (if startDate.day == endDate.day) or a date range in the form of
	// "Formatted Start Date - Formatted End Date" (e.g. "05.10.15 - 10.03.15").
	public func dateRangeDescription(withFormatter dateFormatter: DateFormatter,
									 relativeDescriptionsAllowed: Bool = true) -> String {
		switch self {
		case .custom: break
		case .calendarUnit(let offset, let unit, _) where unit == .month && (!relativeDescriptionsAllowed || offset != 0):
			// Special case: A month, but not the current one. E.g. "October 2015".
			let monthDayFormat = DateFormatter.dateFormat(fromTemplate: "MMMM y", options:0, locale: Locale.current)
			let fullMonthDateFormatter = DateFormatter()
			fullMonthDateFormatter.timeStyle = .none
			fullMonthDateFormatter.dateFormat = monthDayFormat
			return fullMonthDateFormatter.string(from: startDate)
		case .pastDays: fallthrough
		case .calendarUnit: if relativeDescriptionsAllowed, let title = title { return title }
		}
		
		if startDate.drp_beginning(ofCalendarUnit: .day) == endDate.drp_beginning(ofCalendarUnit: .day) {
			return dateFormatter.string(from: endDate)
		}
		//! TODO: Use DateIntervalFormatter here.
		return "\(dateFormatter.string(from: startDate)) \u{2013} \(dateFormatter.string(from: endDate))"  // en dash
	}
	
	// MARK: - Obtaining related ranges
	public func previous() -> DateRange {
		return moveBy(steps: -1)
	}
	
	public func next() -> DateRange {
		return moveBy(steps: 1)
	}
	
	public func moveBy(steps: Int) -> DateRange {
		switch self {
		case .custom, .pastDays:
			// Add one to the distance between start and end date so that for steps = 1, the date ranges do not overlap.
			let dayDifference = (endDate.drp_daysSince(startDate) ?? 0) + 1
			let newStartDate = startDate.drp_addCalendarUnits(dayDifference * steps, unit: .day) ?? startDate
			let newEndDate = endDate.drp_addCalendarUnits(dayDifference * steps, unit: .day) ?? endDate
			let todayRange = DateRange.calendarUnit(0, .day, hourShift: self.hourShift)
			if newEndDate == todayRange.endDate {
				if newStartDate == todayRange.startDate {
					return todayRange
				}
				return .pastDays(dayDifference - 1, hourShift: self.hourShift)
			}
			return .custom(newStartDate, newEndDate, hourShift: self.hourShift)
		case let .calendarUnit(offset, unit, hourShift):
			return .calendarUnit(offset + steps, unit, hourShift: hourShift)
		}
	}
	
	public func restrictTo(minDate: Date?, maxDate: Date?) -> DateRange {
		var adjustedStartDate = startDate
		var adjustedEndDate = endDate
		if let minDate = minDate?.drp_beginning(ofCalendarUnit: .day) {
			adjustedStartDate = (minDate as NSDate).laterDate(adjustedStartDate)
			adjustedEndDate = (minDate as NSDate).laterDate(adjustedEndDate)
		}
		if let maxDate = maxDate?.drp_end(ofCalendarUnit: .day) {
			adjustedStartDate = (maxDate as NSDate).earlierDate(adjustedStartDate)
			adjustedEndDate = (maxDate as NSDate).earlierDate(adjustedEndDate)
		}
		if startDate != adjustedStartDate || endDate != adjustedEndDate {
			return .custom(adjustedStartDate, adjustedEndDate, hourShift: self.hourShift)
		}
		
		return self
	}
	
	// Ugly workaround for serialization because enums can't support NSCoding.
	public func toData() -> Data {
		let data = NSMutableData()
		let archiver = NSKeyedArchiver(forWritingWith: data)
		switch self {
		case let .custom(startDate, endDate, hourShift):
			archiver.encode("Custom", forKey: "case")
			archiver.encode(startDate, forKey: "startDate")
			archiver.encode(endDate, forKey: "endDate")
			archiver.encode(hourShift, forKey: "hourShift")
		case let .pastDays(pastDays, hourShift):
			archiver.encode("PastDays", forKey: "case")
			archiver.encode(pastDays, forKey: "pastDays")
			archiver.encode(hourShift, forKey: "hourShift")
		case let .calendarUnit(offset, unit, hourShift):
			archiver.encode("CalendarUnit", forKey: "case")
			archiver.encode(offset, forKey: "offset")
			archiver.encode(Int(unit.rawValue), forKey: "unit")
			archiver.encode(hourShift, forKey: "hourShift")
		}
		archiver.finishEncoding()
		return data as Data
	}
	
	public static func from(data: Data) -> DateRange? {
		let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
		guard let caseName = unarchiver.decodeObject(forKey: "case") as? String else { return nil }
		switch caseName {
		case "Custom":
			guard let startDate = unarchiver.decodeObject(forKey: "startDate") as? Date else { return nil }
			guard let endDate = unarchiver.decodeObject(forKey: "endDate") as? Date else { return nil }
			return custom(startDate, endDate,
			              hourShift: unarchiver.decodeInteger(forKey: "hourShift"))
		case "PastDays":
			if !unarchiver.containsValue(forKey: "pastDays") { return nil }
			return pastDays(unarchiver.decodeInteger(forKey: "pastDays"),
			                hourShift: unarchiver.decodeInteger(forKey: "hourShift"))
		case "CalendarUnit":
			if !unarchiver.containsValue(forKey: "offset") { return nil }
			if !unarchiver.containsValue(forKey: "unit") { return nil }
			return calendarUnit(unarchiver.decodeInteger(forKey: "offset"),
			                    NSCalendar.Unit(rawValue: UInt(unarchiver.decodeInteger(forKey: "unit"))),
			                    hourShift: unarchiver.decodeInteger(forKey: "hourShift"))
		default:
			return nil
		}
	}
}

public func ==(lhs: DateRange, rhs: DateRange) -> Bool {
	switch (lhs, rhs) {
	case (.custom, .custom):
		return lhs.startDate == rhs.startDate && lhs.endDate == rhs.endDate
	case let (.pastDays(ld, lHourShift), .pastDays(rd, rHourShift)):
		return ld == rd && lHourShift == rHourShift
	case let (.calendarUnit(lo, lu, lHourShift), .calendarUnit(ro, ru, rHourShift)):
		return lo == ro && lu == ru && lHourShift == rHourShift
	default:
		return false
	}
}
