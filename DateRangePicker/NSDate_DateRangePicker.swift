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
	
	public func drp_daysSince(since: NSDate, calendar: NSCalendar) -> Int {
		var fromDate: NSDate?
		var toDate: NSDate?
		calendar.rangeOfUnit(.Day, startDate: &fromDate, interval: nil, forDate: since)
		calendar.rangeOfUnit(.Day, startDate: &toDate, interval: nil, forDate: self)
		
		return calendar.components(.Day, fromDate: fromDate!, toDate: toDate!, options: []).day
	}
	
	// Returns the number of calendar days since the argument and the receiver.
	public func drp_daysSince(since: NSDate) -> Int {
		return drp_daysSince(since, calendar: NSCalendar.currentCalendar())
	}
}
