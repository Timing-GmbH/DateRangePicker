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
	func dateFromString(_ dateString: String) -> Date {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd"
		return dateFormatter.date(from: dateString)!
	}
	
	func dateFromStringWithTime(_ dateString: String) -> Date {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
		return dateFormatter.date(from: dateString)!
	}
	
	func testAddCalendarUnits() {
		XCTAssertEqual(dateFromString("2022-06-03"), dateFromString("2015-06-03").drp_addCalendarUnits(count: 7, .year))
		XCTAssertEqual(dateFromString("2008-06-03"), dateFromString("2015-06-03").drp_addCalendarUnits(count: -7, .year))
		
		XCTAssertEqual(dateFromString("2017-03-03"), dateFromString("2015-06-03").drp_addCalendarUnits(count: 7, .quarter))
		XCTAssertEqual(dateFromString("2013-09-03"), dateFromString("2015-06-03").drp_addCalendarUnits(count: -7, .quarter))
		
		XCTAssertEqual(dateFromString("2016-01-03"), dateFromString("2015-06-03").drp_addCalendarUnits(count: 7, .month))
		XCTAssertEqual(dateFromString("2014-11-03"), dateFromString("2015-06-03").drp_addCalendarUnits(count: -7, .month))
		
		XCTAssertEqual(dateFromString("2015-06-10"), dateFromString("2015-06-03").drp_addCalendarUnits(count: 7, .day))
		XCTAssertEqual(dateFromString("2015-05-27"), dateFromString("2015-06-03").drp_addCalendarUnits(count: -7, .day))
	}
	
	func testDaysSince() {
		XCTAssertEqual(7, dateFromString("2015-06-10").drp_daysSince(since: dateFromString("2015-06-03") as NSDate))
	}
	
	func testDaysSinceWithDSTCalendar() {
		var calendar = Calendar.current
		calendar.timeZone = TimeZone(identifier: "Europe/Berlin")!
		XCTAssertEqual(7, dateFromString("2015-10-27").drp_daysSince(since: dateFromString("2015-10-20") as NSDate, calendar: calendar as NSCalendar))
		XCTAssertEqual(-7, dateFromString("2015-10-20").drp_daysSince(since: dateFromString("2015-10-27") as NSDate, calendar: calendar as NSCalendar))
		
		XCTAssertEqual(0, calendar.timeZone.daylightSavingTimeOffset(for: dateFromString("2015-03-25")))
		XCTAssertEqual(3600, calendar.timeZone.daylightSavingTimeOffset(for: dateFromString("2015-04-01")))
		XCTAssertEqual(7, dateFromString("2015-04-01").drp_daysSince(since: dateFromString("2015-03-25") as NSDate, calendar: calendar as NSCalendar))
		XCTAssertEqual(-7, dateFromString("2015-03-25").drp_daysSince(since: dateFromString("2015-04-01") as NSDate, calendar: calendar as NSCalendar))
	}
	
	func testBeginningOfCalendarUnit() {
		XCTAssertEqual(dateFromString("2015-01-01"), dateFromString("2015-01-01").drp_beginningOfCalendarUnit(unit: .year))
		XCTAssertEqual(dateFromString("2015-01-01"), dateFromString("2015-12-31").drp_beginningOfCalendarUnit(unit: .year))
		
		XCTAssertEqual(dateFromString("2015-04-01"), dateFromString("2015-06-03").drp_beginningOfCalendarUnit(unit: .quarter))
		XCTAssertEqual(dateFromString("2015-01-01"), dateFromString("2015-03-31").drp_beginningOfCalendarUnit(unit: .quarter))
		XCTAssertEqual(dateFromString("2015-10-01"), dateFromString("2015-10-01").drp_beginningOfCalendarUnit(unit: .quarter))
		XCTAssertEqual(dateFromString("2015-01-01"), dateFromString("2015-01-01").drp_beginningOfCalendarUnit(unit: .quarter))
		
		XCTAssertEqual(dateFromString("2015-01-01"), dateFromString("2015-01-01").drp_beginningOfCalendarUnit(unit: .month))
		XCTAssertEqual(dateFromString("2015-12-01"), dateFromString("2015-12-31").drp_beginningOfCalendarUnit(unit: .month))
	}
	
	func testEndOfCalendarUnit() {
		XCTAssertEqual(dateFromStringWithTime("2015-12-31 23:59:59"), dateFromString("2015-01-01").drp_endOfCalendarUnit(unit: .year))
		XCTAssertEqual(dateFromStringWithTime("2015-12-31 23:59:59"), dateFromString("2015-12-31").drp_endOfCalendarUnit(unit: .year))
		
		XCTAssertEqual(dateFromStringWithTime("2015-12-31 23:59:59"), dateFromString("2015-12-31").drp_endOfCalendarUnit(unit: .quarter))
		XCTAssertEqual(dateFromStringWithTime("2015-12-31 23:59:59"), dateFromString("2015-10-01").drp_endOfCalendarUnit(unit: .quarter))
		
		XCTAssertEqual(dateFromStringWithTime("2015-01-31 23:59:59"), dateFromString("2015-01-01").drp_endOfCalendarUnit(unit: .month))
		XCTAssertEqual(dateFromStringWithTime("2015-12-31 23:59:59"), dateFromString("2015-12-31").drp_endOfCalendarUnit(unit: .month))
	}
}
