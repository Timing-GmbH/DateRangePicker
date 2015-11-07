//
//  NSDate_DateRangePicker.swift
//  DateRangePicker
//
//  Created by Daniel Alm on 07.11.15.
//  Copyright © 2015 Daniel Alm. All rights reserved.
//

import Foundation

public extension NSDate {
	// Adds the given number of calendar days to the receiver.
	public func drp_addDays(days: Int) -> NSDate? {
		let calendar = NSCalendar.currentCalendar()
		return calendar.dateByAddingUnit(.Day, value: days, toDate: self, options: [])
	}
	
	public func drp_beginningOfCalendarUnit(unit: NSCalendarUnit, calendar: NSCalendar) -> NSDate? {
		var reducedDate: NSDate?
		calendar.rangeOfUnit(unit, startDate: &reducedDate, interval: nil, forDate: self)
		return reducedDate
	}
	
	public func drp_beginningOfCalendarUnit(unit: NSCalendarUnit) -> NSDate? {
		return drp_beginningOfCalendarUnit(unit, calendar: NSCalendar.currentCalendar())
	}
	
	public func drp_endOfCalendarUnit(unit: NSCalendarUnit, calendar: NSCalendar) -> NSDate? {
		guard let startDate = drp_beginningOfCalendarUnit(unit, calendar: NSCalendar.currentCalendar()) else { return nil }
		let advancedDate: NSDate?
		if (unit == .Quarter) {
			// There seems to be a bug where adding one quarter to a date in the 3rd quarter does not return the
			// corresponding date in the 4th quarter. As a workaround, we add 3 months instead.
			advancedDate = calendar.dateByAddingUnit(.Month, value: 3, toDate: startDate, options: [])
		} else {
			advancedDate = calendar.dateByAddingUnit(unit, value: 1, toDate: startDate, options: [])
		}
		return advancedDate?.dateByAddingTimeInterval(-1)
	}
	
	public func drp_endOfCalendarUnit(unit: NSCalendarUnit) -> NSDate? {
		return drp_endOfCalendarUnit(unit, calendar: NSCalendar.currentCalendar())
	}
	
	public func drp_daysSince(since: NSDate, calendar: NSCalendar) -> Int {
		let fromDate = since.drp_beginningOfCalendarUnit(.Day, calendar: calendar)!
		let toDate = self.drp_beginningOfCalendarUnit(.Day, calendar: calendar)!
		return calendar.components(.Day, fromDate: fromDate, toDate: toDate, options: []).day
	}
	
	// Returns the number of calendar days since the argument and the receiver.
	public func drp_daysSince(since: NSDate) -> Int {
		return drp_daysSince(since, calendar: NSCalendar.currentCalendar())
	}
}
