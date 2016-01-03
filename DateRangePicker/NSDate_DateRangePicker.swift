//
//  NSDate_DateRangePicker.swift
//  DateRangePicker
//
//  Created by Daniel Alm on 07.11.15.
//  Copyright © 2015 Daniel Alm. All rights reserved.
//

import Foundation

public extension NSDate {
	public func drp_addCalendarUnits(count: Int, _ unit: NSCalendarUnit, calendar: NSCalendar = NSCalendar.currentCalendar()) -> NSDate? {
		let advancedDate: NSDate?
		if unit == .Quarter {
			// There seems to be a bug where adding one quarter to a date in the 3rd quarter does not return the
			// corresponding date in the 4th quarter. As a workaround, we add 3 months instead.
			advancedDate = calendar.dateByAddingUnit(.Month, value: 3 * count, toDate: self, options: [])
		} else {
			advancedDate = calendar.dateByAddingUnit(unit, value: count, toDate: self, options: [])
		}
		return advancedDate
	}
	
	public func drp_beginningOfCalendarUnit(unit: NSCalendarUnit, calendar: NSCalendar = NSCalendar.currentCalendar()) -> NSDate? {
		var reducedDate: NSDate?
		calendar.rangeOfUnit(unit, startDate: &reducedDate, interval: nil, forDate: self)
		return reducedDate
	}
	
	public func drp_endOfCalendarUnit(unit: NSCalendarUnit, calendar: NSCalendar = NSCalendar.currentCalendar()) -> NSDate? {
		guard let startDate = drp_beginningOfCalendarUnit(unit, calendar: NSCalendar.currentCalendar()) else { return nil }
		return startDate.drp_addCalendarUnits(1, unit, calendar: calendar)?.dateByAddingTimeInterval(-1)
	}
	
	// Returns the number of calendar days between the argument and the receiver.
	public func drp_daysSince(since: NSDate, calendar: NSCalendar = NSCalendar.currentCalendar()) -> Int {
		let fromDate = since.drp_beginningOfCalendarUnit(.Day, calendar: calendar)!
		let toDate = self.drp_beginningOfCalendarUnit(.Day, calendar: calendar)!
		return calendar.components(.Day, fromDate: fromDate, toDate: toDate, options: []).day
	}
}
