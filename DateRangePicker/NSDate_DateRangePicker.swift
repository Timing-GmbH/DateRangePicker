//
//  NSDate_DateRangePicker.swift
//  DateRangePicker
//
//  Created by Daniel Alm on 07.11.15.
//  Copyright © 2015 Daniel Alm. All rights reserved.
//

import Foundation

//! CLEANUP: Migrate these APIs from NSCalendar.Unit to Calendar.Component.
public extension Date {
	public func drp_addCalendarUnits(_ count: Int, unit: NSCalendar.Unit, calendar: Calendar = Calendar.current) -> Date? {
		let advancedDate: Date?
		if unit == .quarter {
			// There seems to be a bug where adding one quarter to a date in the 3rd quarter does not return the
			// corresponding date in the 4th quarter. As a workaround, we add 3 months instead.
			advancedDate = (calendar as NSCalendar).date(byAdding: .month, value: 3 * count, to: self, options: [])
		} else {
			advancedDate = (calendar as NSCalendar).date(byAdding: unit, value: count, to: self, options: [])
		}
		return advancedDate
	}
	
	public func drp_beginning(ofCalendarUnit unit: NSCalendar.Unit, calendar: Calendar = Calendar.current) -> Date? {
		var reducedDate: NSDate?
		(calendar as NSCalendar).range(of: unit, start: &reducedDate, interval: nil, for: self)
		return reducedDate as Date?
	}
	
	public func drp_end(ofCalendarUnit unit: NSCalendar.Unit, calendar: Calendar = Calendar.current) -> Date? {
		guard let startDate = drp_beginning(ofCalendarUnit: unit, calendar: Calendar.current) else { return nil }
		return startDate.drp_addCalendarUnits(1, unit: unit, calendar: calendar)?.addingTimeInterval(-1)
	}
	
	public func drp_calendarUnits(since: Date, unit: NSCalendar.Unit, calendar: Calendar = Calendar.current) -> Int {
		let fromDate = since.drp_beginning(ofCalendarUnit: unit, calendar: calendar)!
		let toDate = self.drp_beginning(ofCalendarUnit: unit, calendar: calendar)!
		return ((calendar as NSCalendar).components(unit, from: fromDate, to: toDate, options: []) as NSDateComponents).value(forComponent: unit)
	}
	
	// Returns the number of calendar days between the argument and the receiver.
	public func drp_daysSince(_ since: Date, calendar: Calendar = Calendar.current) -> Int {
		return self.drp_calendarUnits(since: since, unit: .day, calendar: calendar)
	}
}

// Required for backwards compatibility with Objective-C.
public extension NSDate {
	public func drp_addCalendarUnits(_ count: Int, unit: NSCalendar.Unit, calendar: Calendar = Calendar.current) -> NSDate? {
		return (self as Date).drp_addCalendarUnits(count, unit: unit, calendar: calendar) as NSDate?
	}
	
	public func drp_beginning(ofCalendarUnit unit: NSCalendar.Unit, calendar: Calendar = Calendar.current) -> NSDate? {
		return (self as Date).drp_beginning(ofCalendarUnit: unit, calendar: calendar) as NSDate?
	}
	
	public func drp_end(ofCalendarUnit unit: NSCalendar.Unit, calendar: Calendar = Calendar.current) -> NSDate? {
		return (self as Date).drp_end(ofCalendarUnit: unit, calendar: calendar) as NSDate?
	}
	
	public func drp_calendarUnits(since: NSDate, unit: NSCalendar.Unit, calendar: Calendar = Calendar.current) -> Int {
		return (self as Date).drp_calendarUnits(since: since as Date, unit: unit, calendar: calendar)
	}
	
	// Returns the number of calendar days between the argument and the receiver.
	public func drp_daysSince(_ since: NSDate, calendar: Calendar = Calendar.current) -> Int {
		return (self as Date).drp_daysSince(since as Date, calendar: calendar)
	}
}
