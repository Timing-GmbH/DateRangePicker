//
//  NSDate_DateRangePickerTest.swift
//  DateRangePicker
//
//  Created by Daniel Alm on 07.11.15.
//  Copyright © 2015 Daniel Alm. All rights reserved.
//

import XCTest

import DateRangePicker

class NSDate_DateRangePickerTest: XCTestCase {
	func dateFromString(dateString: String) -> NSDate {
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd"
		return dateFormatter.dateFromString(dateString)!
	}
	
	func dateFromStringWithTime(dateString: String) -> NSDate {
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
		return dateFormatter.dateFromString(dateString)!
	}
	
	func testAddCalendarUnits() {
		XCTAssertEqual(dateFromString("2022-06-03"), dateFromString("2015-06-03").drp_addCalendarUnits(7, .Year))
		XCTAssertEqual(dateFromString("2008-06-03"), dateFromString("2015-06-03").drp_addCalendarUnits(-7, .Year))
		
		XCTAssertEqual(dateFromString("2017-03-03"), dateFromString("2015-06-03").drp_addCalendarUnits(7, .Quarter))
		XCTAssertEqual(dateFromString("2013-09-03"), dateFromString("2015-06-03").drp_addCalendarUnits(-7, .Quarter))
		
		XCTAssertEqual(dateFromString("2016-01-03"), dateFromString("2015-06-03").drp_addCalendarUnits(7, .Month))
		XCTAssertEqual(dateFromString("2014-11-03"), dateFromString("2015-06-03").drp_addCalendarUnits(-7, .Month))
		
		XCTAssertEqual(dateFromString("2015-06-10"), dateFromString("2015-06-03").drp_addCalendarUnits(7, .Day))
		XCTAssertEqual(dateFromString("2015-05-27"), dateFromString("2015-06-03").drp_addCalendarUnits(-7, .Day))
		
		XCTAssertEqual(dateFromString("2016-01-06"), dateFromString("2015-12-30").drp_addCalendarUnits(7, .Day))
	}
	
	func testDaysSince() {
		XCTAssertEqual(7, dateFromString("2015-06-10").drp_daysSince(dateFromString("2015-06-03")))
	}
	
	func testDaysSinceWithDSTCalendar() {
		let calendar = NSCalendar.currentCalendar()
		calendar.timeZone = NSTimeZone(name: "Europe/Berlin")!
		XCTAssertEqual(7, dateFromString("2015-10-27").drp_daysSince(dateFromString("2015-10-20"), calendar: calendar))
		XCTAssertEqual(-7, dateFromString("2015-10-20").drp_daysSince(dateFromString("2015-10-27"), calendar: calendar))
		
		XCTAssertEqual(0, calendar.timeZone.daylightSavingTimeOffsetForDate(dateFromString("2015-03-25")))
		XCTAssertEqual(3600, calendar.timeZone.daylightSavingTimeOffsetForDate(dateFromString("2015-04-01")))
		XCTAssertEqual(7, dateFromString("2015-04-01").drp_daysSince(dateFromString("2015-03-25"), calendar: calendar))
		XCTAssertEqual(-7, dateFromString("2015-03-25").drp_daysSince(dateFromString("2015-04-01"), calendar: calendar))
	}
	
	func testBeginningOfCalendarUnit() {
		XCTAssertEqual(dateFromString("2015-01-01"), dateFromString("2015-01-01").drp_beginningOfCalendarUnit(.Year))
		XCTAssertEqual(dateFromString("2015-01-01"), dateFromString("2015-12-31").drp_beginningOfCalendarUnit(.Year))
		
		XCTAssertEqual(dateFromString("2015-04-01"), dateFromString("2015-06-03").drp_beginningOfCalendarUnit(.Quarter))
		XCTAssertEqual(dateFromString("2015-01-01"), dateFromString("2015-03-31").drp_beginningOfCalendarUnit(.Quarter))
		XCTAssertEqual(dateFromString("2015-10-01"), dateFromString("2015-10-01").drp_beginningOfCalendarUnit(.Quarter))
		XCTAssertEqual(dateFromString("2015-01-01"), dateFromString("2015-01-01").drp_beginningOfCalendarUnit(.Quarter))
		
		XCTAssertEqual(dateFromString("2015-01-01"), dateFromString("2015-01-01").drp_beginningOfCalendarUnit(.Month))
		XCTAssertEqual(dateFromString("2015-12-01"), dateFromString("2015-12-31").drp_beginningOfCalendarUnit(.Month))
	}
	
	func testEndOfCalendarUnit() {
		XCTAssertEqual(dateFromStringWithTime("2015-12-31 23:59:59"), dateFromString("2015-01-01").drp_endOfCalendarUnit(.Year))
		XCTAssertEqual(dateFromStringWithTime("2015-12-31 23:59:59"), dateFromString("2015-12-31").drp_endOfCalendarUnit(.Year))
		
		XCTAssertEqual(dateFromStringWithTime("2015-12-31 23:59:59"), dateFromString("2015-12-31").drp_endOfCalendarUnit(.Quarter))
		XCTAssertEqual(dateFromStringWithTime("2015-12-31 23:59:59"), dateFromString("2015-10-01").drp_endOfCalendarUnit(.Quarter))
		
		XCTAssertEqual(dateFromStringWithTime("2015-01-31 23:59:59"), dateFromString("2015-01-01").drp_endOfCalendarUnit(.Month))
		XCTAssertEqual(dateFromStringWithTime("2015-12-31 23:59:59"), dateFromString("2015-12-31").drp_endOfCalendarUnit(.Month))
	}
}
