//
//  DateRangeTest.swift
//  DateRangePicker
//
//  Created by Daniel Alm on 08.11.15.
//  Copyright © 2015 Daniel Alm. All rights reserved.
//

import XCTest

import DateRangePicker

class DateRangeTest: XCTestCase {
	func dateFromString(dateString: String) -> NSDate {
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd"
		return dateFormatter.dateFromString(dateString)!
	}
	
	func testTitle() {
		XCTAssertEqual("Custom", DateRange.Custom(NSDate(), NSDate()).title)
		
		XCTAssertEqual("Past 7 days", DateRange.PastDays(7).title)
		
		XCTAssertEqual("This Quarter", DateRange.CalendarUnit(0, .Quarter).title)
		XCTAssertEqual("1 Quarter ago", DateRange.CalendarUnit(-1, .Quarter).title)
		XCTAssertEqual("1 Quarter in the future", DateRange.CalendarUnit(1, .Quarter).title)
		
		XCTAssertEqual("None", DateRange.None.title)
	}
	
	func testStartEndDates() {
		let startDate = dateFromString("2015-06-15")
		let endDate = dateFromString("2015-06-17")
		
		var dateRange = DateRange.Custom(startDate, endDate)
		XCTAssertEqual(startDate, dateRange.startDate)
		XCTAssertEqual(endDate.drp_endOfCalendarUnit(.Day), dateRange.endDate)
		
		// Being able to specify a reference date would be nicer for testability,
		// but then the API would likely get very unwieldy.
		dateRange = DateRange.PastDays(30)
		XCTAssertEqual(NSDate().drp_addCalendarUnits(-30, .Day)!.drp_beginningOfCalendarUnit(.Day), dateRange.startDate)
		XCTAssertEqual(NSDate().drp_endOfCalendarUnit(.Day), dateRange.endDate)
		
		dateRange = DateRange.CalendarUnit(0, .Quarter)
		XCTAssertEqual(NSDate().drp_beginningOfCalendarUnit(.Quarter), dateRange.startDate)
		XCTAssertEqual(NSDate().drp_endOfCalendarUnit(.Quarter), dateRange.endDate)
		
		dateRange = DateRange.CalendarUnit(-1, .Quarter)
		XCTAssertEqual(NSDate().drp_addCalendarUnits(-1, .Quarter)!.drp_beginningOfCalendarUnit(.Quarter), dateRange.startDate)
		XCTAssertEqual(NSDate().drp_addCalendarUnits(-1, .Quarter)!.drp_endOfCalendarUnit(.Quarter), dateRange.endDate)
		
		dateRange = DateRange.CalendarUnit(1, .Quarter)
		XCTAssertEqual(NSDate().drp_addCalendarUnits(1, .Quarter)!.drp_beginningOfCalendarUnit(.Quarter), dateRange.startDate)
		XCTAssertEqual(NSDate().drp_addCalendarUnits(1, .Quarter)!.drp_endOfCalendarUnit(.Quarter), dateRange.endDate)
		
		dateRange = DateRange.None
		XCTAssertEqual(nil, DateRange.None.startDate)
		XCTAssertEqual(nil, DateRange.None.endDate)
	}
	
	func testEqual() {
		let startDate = dateFromString("2015-06-15")
		let endDate = dateFromString("2015-06-17")
		XCTAssertEqual(DateRange.Custom(startDate, endDate), DateRange.Custom(startDate, endDate))
		// Custom date ranges are compared on a per-day basis, not per-second.
		XCTAssertEqual(DateRange.Custom(startDate.dateByAddingTimeInterval(3600), endDate.dateByAddingTimeInterval(3600)), DateRange.Custom(startDate, endDate))
		XCTAssertNotEqual(DateRange.Custom(dateFromString("2015-06-14"), endDate), DateRange.Custom(startDate, endDate))
		
		XCTAssertEqual(DateRange.PastDays(7), DateRange.PastDays(7))
		XCTAssertNotEqual(DateRange.PastDays(7), DateRange.PastDays(8))
		
		XCTAssertEqual(DateRange.CalendarUnit(7, .Quarter), DateRange.CalendarUnit(7, .Quarter))
		XCTAssertNotEqual(DateRange.CalendarUnit(8, .Quarter), DateRange.CalendarUnit(7, .Quarter))
		XCTAssertNotEqual(DateRange.CalendarUnit(7, .Day), DateRange.CalendarUnit(7, .Quarter))
		XCTAssertNotEqual(DateRange.CalendarUnit(1, .WeekOfYear), DateRange.CalendarUnit(7, .Day))
		
		XCTAssertEqual(DateRange.None, DateRange.None)
	}
	
	func testMoveBy() {
		let startDate = dateFromString("2015-06-15")
		let endDate = dateFromString("2015-06-17")
		
		XCTAssertEqual(DateRange.Custom(dateFromString("2015-06-09"), dateFromString("2015-06-11")), DateRange.Custom(startDate, endDate).moveBy(-2))
		
		XCTAssertEqual(DateRange.Custom(NSDate().drp_addCalendarUnits(-92, .Day)!, NSDate().drp_addCalendarUnits(-62, .Day)!),
			DateRange.PastDays(30).moveBy(-2))
		
		XCTAssertEqual(DateRange.CalendarUnit(-1, .Quarter), DateRange.CalendarUnit(1, .Quarter).moveBy(-2))
		XCTAssertEqual(DateRange.None, DateRange.None.moveBy(-2))
	}
}
