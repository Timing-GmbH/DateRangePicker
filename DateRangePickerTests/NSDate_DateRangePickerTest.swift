//
//  NSDate_DateRangePickerTest.swift
//  DateRangePicker
//
//  Created by Daniel Alm on 07.11.15.
//  Copyright © 2015 Daniel Alm. All rights reserved.
//

import XCTest

import DateRangePicker

class Date_DateRangePickerTest: XCTestCase {
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
		XCTAssertEqual(dateFromString("2022-06-03"), dateFromString("2015-06-03").drp_addCalendarUnits(7, unit: .year))
		XCTAssertEqual(dateFromString("2008-06-03"), dateFromString("2015-06-03").drp_addCalendarUnits(-7, unit: .year))
		
		XCTAssertEqual(dateFromString("2017-03-03"), dateFromString("2015-06-03").drp_addCalendarUnits(7, unit: .quarter))
		XCTAssertEqual(dateFromString("2013-09-03"), dateFromString("2015-06-03").drp_addCalendarUnits(-7, unit: .quarter))
		
		XCTAssertEqual(dateFromString("2016-01-03"), dateFromString("2015-06-03").drp_addCalendarUnits(7, unit: .month))
		XCTAssertEqual(dateFromString("2014-11-03"), dateFromString("2015-06-03").drp_addCalendarUnits(-7, unit: .month))
		
		XCTAssertEqual(dateFromString("2015-06-10"), dateFromString("2015-06-03").drp_addCalendarUnits(7, unit: .day))
		XCTAssertEqual(dateFromString("2015-05-27"), dateFromString("2015-06-03").drp_addCalendarUnits(-7, unit: .day))
		
		XCTAssertEqual(dateFromString("2016-01-06"), dateFromString("2015-12-30").drp_addCalendarUnits(7, unit: .day))
	}
	
	func testDaysSince() {
		XCTAssertEqual(7, dateFromString("2015-06-10").drp_daysSince(dateFromString("2015-06-03")))
	}
	
	func testDaysSinceWithDSTCalendar() {
		var calendar = Calendar.current
		calendar.timeZone = TimeZone(identifier: "Europe/Berlin")!
		XCTAssertEqual(7, dateFromString("2015-10-27").drp_daysSince(dateFromString("2015-10-20"), calendar: calendar))
		XCTAssertEqual(-7, dateFromString("2015-10-20").drp_daysSince(dateFromString("2015-10-27"), calendar: calendar))
		
		XCTAssertEqual(0, calendar.timeZone.daylightSavingTimeOffset(for: dateFromString("2015-03-25")))
		XCTAssertEqual(3600, calendar.timeZone.daylightSavingTimeOffset(for: dateFromString("2015-04-01")))
		XCTAssertEqual(7, dateFromString("2015-04-01").drp_daysSince(dateFromString("2015-03-25"), calendar: calendar))
		XCTAssertEqual(-7, dateFromString("2015-03-25").drp_daysSince(dateFromString("2015-04-01"), calendar: calendar))
	}
	
	func testBeginningOfCalendarUnit() {
		XCTAssertEqual(dateFromString("2015-01-01"), dateFromString("2015-01-01").drp_beginning(ofCalendarUnit: .year))
		XCTAssertEqual(dateFromString("2015-01-01"), dateFromString("2015-12-31").drp_beginning(ofCalendarUnit: .year))
		
		XCTAssertEqual(dateFromString("2015-04-01"), dateFromString("2015-06-03").drp_beginning(ofCalendarUnit: .quarter))
		XCTAssertEqual(dateFromString("2015-01-01"), dateFromString("2015-03-31").drp_beginning(ofCalendarUnit: .quarter))
		XCTAssertEqual(dateFromString("2015-10-01"), dateFromString("2015-10-01").drp_beginning(ofCalendarUnit: .quarter))
		XCTAssertEqual(dateFromString("2015-01-01"), dateFromString("2015-01-01").drp_beginning(ofCalendarUnit: .quarter))
		
		XCTAssertEqual(dateFromString("2015-01-01"), dateFromString("2015-01-01").drp_beginning(ofCalendarUnit: .month))
		XCTAssertEqual(dateFromString("2015-12-01"), dateFromString("2015-12-31").drp_beginning(ofCalendarUnit: .month))
	}
	
	func testEndOfCalendarUnit() {
		XCTAssertEqual(dateFromStringWithTime("2015-12-31 23:59:59"), dateFromString("2015-01-01").drp_end(ofCalendarUnit: .year))
		XCTAssertEqual(dateFromStringWithTime("2015-12-31 23:59:59"), dateFromString("2015-12-31").drp_end(ofCalendarUnit: .year))
		
		XCTAssertEqual(dateFromStringWithTime("2015-12-31 23:59:59"), dateFromString("2015-12-31").drp_end(ofCalendarUnit: .quarter))
		XCTAssertEqual(dateFromStringWithTime("2015-12-31 23:59:59"), dateFromString("2015-10-01").drp_end(ofCalendarUnit: .quarter))
		
		XCTAssertEqual(dateFromStringWithTime("2015-01-31 23:59:59"), dateFromString("2015-01-01").drp_end(ofCalendarUnit: .month))
		XCTAssertEqual(dateFromStringWithTime("2015-12-31 23:59:59"), dateFromString("2015-12-31").drp_end(ofCalendarUnit: .month))
	}
	
	func testEndOfCalendarUnitWithoutAdjusting() {
		XCTAssertEqual(dateFromStringWithTime("2016-01-01 00:00:00"), dateFromString("2015-01-01").drp_end(ofCalendarUnit: .year, adjustByOneSecond: false))
		XCTAssertEqual(dateFromStringWithTime("2016-01-01 00:00:00"), dateFromString("2015-12-31").drp_end(ofCalendarUnit: .year, adjustByOneSecond: false))
		
		XCTAssertEqual(dateFromStringWithTime("2016-01-01 00:00:00"), dateFromString("2015-12-31").drp_end(ofCalendarUnit: .quarter, adjustByOneSecond: false))
		XCTAssertEqual(dateFromStringWithTime("2016-01-01 00:00:00"), dateFromString("2015-10-01").drp_end(ofCalendarUnit: .quarter, adjustByOneSecond: false))
		
		XCTAssertEqual(dateFromStringWithTime("2015-02-01 00:00:00"), dateFromString("2015-01-01").drp_end(ofCalendarUnit: .month, adjustByOneSecond: false))
		XCTAssertEqual(dateFromStringWithTime("2016-01-01 00:00:00"), dateFromString("2015-12-31").drp_end(ofCalendarUnit: .month, adjustByOneSecond: false))
	}
}

class NSDate_DateRangePickerTest: XCTestCase {
	func dateFromString(_ dateString: String) -> NSDate {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd"
		return dateFormatter.date(from: dateString)! as NSDate
	}
	
	func dateFromStringWithTime(_ dateString: String) -> NSDate {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
		return dateFormatter.date(from: dateString)! as NSDate
	}
	
	func testAddCalendarUnits() {
		XCTAssertEqual(dateFromString("2022-06-03"), dateFromString("2015-06-03").drp_addCalendarUnits(7, unit: .year))
		XCTAssertEqual(dateFromString("2008-06-03"), dateFromString("2015-06-03").drp_addCalendarUnits(-7, unit: .year))
		
		XCTAssertEqual(dateFromString("2017-03-03"), dateFromString("2015-06-03").drp_addCalendarUnits(7, unit: .quarter))
		XCTAssertEqual(dateFromString("2013-09-03"), dateFromString("2015-06-03").drp_addCalendarUnits(-7, unit: .quarter))
		
		XCTAssertEqual(dateFromString("2016-01-03"), dateFromString("2015-06-03").drp_addCalendarUnits(7, unit: .month))
		XCTAssertEqual(dateFromString("2014-11-03"), dateFromString("2015-06-03").drp_addCalendarUnits(-7, unit: .month))
		
		XCTAssertEqual(dateFromString("2015-06-10"), dateFromString("2015-06-03").drp_addCalendarUnits(7, unit: .day))
		XCTAssertEqual(dateFromString("2015-05-27"), dateFromString("2015-06-03").drp_addCalendarUnits(-7, unit: .day))
		
		XCTAssertEqual(dateFromString("2016-01-06"), dateFromString("2015-12-30").drp_addCalendarUnits(7, unit: .day))
	}
	
	func testDaysSince() {
		XCTAssertEqual(7, dateFromString("2015-06-10").drp_daysSince(dateFromString("2015-06-03")))
	}
	
	func testDaysSinceWithDSTCalendar() {
		var calendar = Calendar.current
		calendar.timeZone = TimeZone(identifier: "Europe/Berlin")!
		XCTAssertEqual(7, dateFromString("2015-10-27").drp_daysSince(dateFromString("2015-10-20"), calendar: calendar))
		XCTAssertEqual(-7, dateFromString("2015-10-20").drp_daysSince(dateFromString("2015-10-27"), calendar: calendar))
		
		XCTAssertEqual(0, calendar.timeZone.daylightSavingTimeOffset(for: dateFromString("2015-03-25") as Date))
		XCTAssertEqual(3600, calendar.timeZone.daylightSavingTimeOffset(for: dateFromString("2015-04-01") as Date))
		XCTAssertEqual(7, dateFromString("2015-04-01").drp_daysSince(dateFromString("2015-03-25"), calendar: calendar))
		XCTAssertEqual(-7, dateFromString("2015-03-25").drp_daysSince(dateFromString("2015-04-01"), calendar: calendar))
	}
	
	func testBeginningOfCalendarUnit() {
		XCTAssertEqual(dateFromString("2015-01-01"), dateFromString("2015-01-01").drp_beginning(ofCalendarUnit: .year))
		XCTAssertEqual(dateFromString("2015-01-01"), dateFromString("2015-12-31").drp_beginning(ofCalendarUnit: .year))
		
		XCTAssertEqual(dateFromString("2015-04-01"), dateFromString("2015-06-03").drp_beginning(ofCalendarUnit: .quarter))
		XCTAssertEqual(dateFromString("2015-01-01"), dateFromString("2015-03-31").drp_beginning(ofCalendarUnit: .quarter))
		XCTAssertEqual(dateFromString("2015-10-01"), dateFromString("2015-10-01").drp_beginning(ofCalendarUnit: .quarter))
		XCTAssertEqual(dateFromString("2015-01-01"), dateFromString("2015-01-01").drp_beginning(ofCalendarUnit: .quarter))
		
		XCTAssertEqual(dateFromString("2015-01-01"), dateFromString("2015-01-01").drp_beginning(ofCalendarUnit: .month))
		XCTAssertEqual(dateFromString("2015-12-01"), dateFromString("2015-12-31").drp_beginning(ofCalendarUnit: .month))
	}
	
	func testEndOfCalendarUnit() {
		XCTAssertEqual(dateFromStringWithTime("2015-12-31 23:59:59"), dateFromString("2015-01-01").drp_end(ofCalendarUnit: .year))
		XCTAssertEqual(dateFromStringWithTime("2015-12-31 23:59:59"), dateFromString("2015-12-31").drp_end(ofCalendarUnit: .year))
		
		XCTAssertEqual(dateFromStringWithTime("2015-12-31 23:59:59"), dateFromString("2015-12-31").drp_end(ofCalendarUnit: .quarter))
		XCTAssertEqual(dateFromStringWithTime("2015-12-31 23:59:59"), dateFromString("2015-10-01").drp_end(ofCalendarUnit: .quarter))
		
		XCTAssertEqual(dateFromStringWithTime("2015-01-31 23:59:59"), dateFromString("2015-01-01").drp_end(ofCalendarUnit: .month))
		XCTAssertEqual(dateFromStringWithTime("2015-12-31 23:59:59"), dateFromString("2015-12-31").drp_end(ofCalendarUnit: .month))
	}
}
