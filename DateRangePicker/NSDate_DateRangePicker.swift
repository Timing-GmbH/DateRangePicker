//
//  NSDate_DateRangePicker.swift
//  DateRangePicker
//
//  Created by Daniel Alm on 07.11.15.
//  Copyright © 2015 Daniel Alm. All rights reserved.
//

import Foundation

public extension NSDate {
	public func drp_addCalendarUnits(count: Int, _ unit: NSCalendar.Unit, calendar: NSCalendar) -> NSDate? {
		let advancedDate: NSDate?
		if unit == .quarter {
			// There seems to be a bug where adding one quarter to a date in the 3rd quarter does not return the
			// corresponding date in the 4th quarter. As a workaround, we add 3 months instead.
			advancedDate = calendar.date(byAdding: .month, value: 3 * count, to: self as Date, options: []) as NSDate?
		} else {
			advancedDate = calendar.date(byAdding: unit, value: count, to: self as Date, options: []) as NSDate?
		}
		return advancedDate
	}
	public func drp_addCalendarUnits(count: Int, _ unit: NSCalendar.Unit) -> NSDate? {
		return drp_addCalendarUnits(count: count, unit, calendar: NSCalendar.current as NSCalendar)
	}
	
	public func drp_beginningOfCalendarUnit(unit: NSCalendar.Unit, calendar: NSCalendar) -> NSDate? {
		var reducedDate: NSDate?
		calendar.range(of: unit, start: &reducedDate, interval: nil, for: self as Date)
		return reducedDate
	}
	public func drp_beginningOfCalendarUnit(unit: NSCalendar.Unit) -> NSDate? {
		return drp_beginningOfCalendarUnit(unit: unit, calendar: NSCalendar.current as NSCalendar)
	}
	
	public func drp_endOfCalendarUnit(unit: NSCalendar.Unit, calendar: NSCalendar) -> NSDate? {
		guard let startDate = drp_beginningOfCalendarUnit(unit: unit, calendar: NSCalendar.current as NSCalendar) else { return nil }
		return startDate.drp_addCalendarUnits(count: 1, unit, calendar: calendar)?.addingTimeInterval(-1)
	}
	public func drp_endOfCalendarUnit(unit: NSCalendar.Unit) -> NSDate? {
		return drp_endOfCalendarUnit(unit: unit, calendar: NSCalendar.current as NSCalendar)
	}
	
	// Returns the number of calendar days between the argument and the receiver.
	public func drp_daysSince(since: NSDate, calendar: NSCalendar) -> Int {
		let fromDate = since.drp_beginningOfCalendarUnit(unit: .day, calendar: calendar)!
		let toDate = self.drp_beginningOfCalendarUnit(unit: .day, calendar: calendar)!
		return calendar.components(.day, from: fromDate as Date, to: toDate as Date, options: []).day!
	}
	public func drp_daysSince(since: NSDate) -> Int {
		return drp_daysSince(since: since, calendar: NSCalendar.current as NSCalendar)
	}
}

public extension Date {
	public func drp_addCalendarUnits(count: Int, _ unit: NSCalendar.Unit, calendar: NSCalendar) -> Date? {
		let selfAsNSDate = self as NSDate
		return selfAsNSDate.drp_addCalendarUnits(count: count, unit, calendar: calendar) as? Date
	}
	
	public func drp_addCalendarUnits(count: Int, _ unit: NSCalendar.Unit) -> Date? {
		let selfAsNSDate = self as NSDate
		return selfAsNSDate.drp_addCalendarUnits(count: count, unit) as? Date
	}
	
	public func drp_beginningOfCalendarUnit(unit: NSCalendar.Unit, calendar: NSCalendar) -> Date? {
		let selfAsNSDate = self as NSDate
		return selfAsNSDate.drp_beginningOfCalendarUnit(unit: unit, calendar: calendar) as? Date
	}
	public func drp_beginningOfCalendarUnit(unit: NSCalendar.Unit) -> Date? {
		let selfAsNSDate = self as NSDate
		return selfAsNSDate.drp_beginningOfCalendarUnit(unit: unit) as? Date
	}
	
	public func drp_endOfCalendarUnit(unit: NSCalendar.Unit, calendar: NSCalendar) -> Date? {
		let selfAsNSDate = self as NSDate
		return selfAsNSDate.drp_endOfCalendarUnit(unit: unit, calendar: calendar) as? Date
	}
	public func drp_endOfCalendarUnit(unit: NSCalendar.Unit) -> Date? {
		let selfAsNSDate = self as NSDate
		return selfAsNSDate.drp_endOfCalendarUnit(unit: unit) as? Date
	}
	
	// Returns the number of calendar days between the argument and the receiver.
	public func drp_daysSince(since: NSDate, calendar: NSCalendar) -> Int {
		let fromDate = since.drp_beginningOfCalendarUnit(unit: .day, calendar: calendar)!
		let toDate = self.drp_beginningOfCalendarUnit(unit: .day, calendar: calendar)!
		return calendar.components(.day, from: fromDate as Date, to: toDate as Date, options: []).day!
	}
	public func drp_daysSince(since: NSDate) -> Int {
		return drp_daysSince(since: since, calendar: NSCalendar.current as NSCalendar)
	}
}
