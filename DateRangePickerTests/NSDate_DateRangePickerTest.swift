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
	static let staticCalendar: Calendar = {
		var calendar = Calendar(identifier: .gregorian)
		calendar.locale = Locale(identifier: "en_DE")
		calendar.timeZone = TimeZone(identifier: "Europe/Berlin")!
		return calendar
	}()
	
	let calendar = Date_DateRangePickerTest.staticCalendar
	
	let dateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd"
		dateFormatter.calendar = staticCalendar
		dateFormatter.locale = staticCalendar.locale
		dateFormatter.timeZone = staticCalendar.timeZone
		return dateFormatter
	}()
	
	let dateFormatterWithTime: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
		dateFormatter.calendar = staticCalendar
		dateFormatter.locale = staticCalendar.locale
		dateFormatter.timeZone = staticCalendar.timeZone
		return dateFormatter
	}()
	
	let isoDateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
		dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
		return dateFormatter
	}()
	
	func dateFromString(_ dateString: String) -> Date {
		return dateFormatter.date(from: dateString)!
	}
	
	func dateFromStringWithTime(_ dateString: String) -> Date {
		return dateFormatterWithTime.date(from: dateString)!
	}
	
	func isoDate(_ dateString: String) -> Date {
		return isoDateFormatter.date(from: dateString)!
	}
	
	func testAddCalendarUnits() {
		XCTAssertEqual(dateFromString("2022-06-03"), dateFromString("2015-06-03").drp_addCalendarUnits(7, unit: .year, calendar: calendar))
		XCTAssertEqual(dateFromString("2008-06-03"), dateFromString("2015-06-03").drp_addCalendarUnits(-7, unit: .year, calendar: calendar))
		
		XCTAssertEqual(dateFromString("2017-03-03"), dateFromString("2015-06-03").drp_addCalendarUnits(7, unit: .quarter, calendar: calendar))
		XCTAssertEqual(dateFromString("2013-09-03"), dateFromString("2015-06-03").drp_addCalendarUnits(-7, unit: .quarter, calendar: calendar))
		
		XCTAssertEqual(dateFromString("2016-01-03"), dateFromString("2015-06-03").drp_addCalendarUnits(7, unit: .month, calendar: calendar))
		XCTAssertEqual(dateFromString("2014-11-03"), dateFromString("2015-06-03").drp_addCalendarUnits(-7, unit: .month, calendar: calendar))
		
		XCTAssertEqual(dateFromString("2015-06-10"), dateFromString("2015-06-03").drp_addCalendarUnits(7, unit: .day, calendar: calendar))
		XCTAssertEqual(dateFromString("2015-05-27"), dateFromString("2015-06-03").drp_addCalendarUnits(-7, unit: .day, calendar: calendar))
		
		XCTAssertEqual(dateFromString("2016-01-06"), dateFromString("2015-12-30").drp_addCalendarUnits(7, unit: .day, calendar: calendar))
	}
	
	func testDaysSince() {
		XCTAssertEqual(7, dateFromString("2015-06-10").drp_daysSince(dateFromString("2015-06-03"), calendar: calendar))
	}
	
	func testDaysSinceWithDSTCalendar() {
		XCTAssertEqual(7, dateFromString("2015-10-27").drp_daysSince(dateFromString("2015-10-20"), calendar: calendar))
		XCTAssertEqual(-7, dateFromString("2015-10-20").drp_daysSince(dateFromString("2015-10-27"), calendar: calendar))
		
		XCTAssertEqual(0, calendar.timeZone.daylightSavingTimeOffset(for: dateFromString("2015-03-25")))
		XCTAssertEqual(3600, calendar.timeZone.daylightSavingTimeOffset(for: dateFromString("2015-04-01")))
		XCTAssertEqual(7, dateFromString("2015-04-01").drp_daysSince(dateFromString("2015-03-25"), calendar: calendar))
		XCTAssertEqual(-7, dateFromString("2015-03-25").drp_daysSince(dateFromString("2015-04-01"), calendar: calendar))
	}
	
	func testBeginningOfCalendarUnit() {
		XCTAssertEqual(dateFromString("2015-01-01"), dateFromString("2015-01-01").drp_beginning(ofCalendarUnit: .year, calendar: calendar))
		XCTAssertEqual(dateFromString("2015-01-01"), dateFromString("2015-12-31").drp_beginning(ofCalendarUnit: .year, calendar: calendar))
		
		XCTAssertEqual(dateFromString("2015-04-01"), dateFromString("2015-06-03").drp_beginning(ofCalendarUnit: .quarter, calendar: calendar))
		XCTAssertEqual(dateFromString("2015-01-01"), dateFromString("2015-03-31").drp_beginning(ofCalendarUnit: .quarter, calendar: calendar))
		XCTAssertEqual(dateFromString("2015-10-01"), dateFromString("2015-10-01").drp_beginning(ofCalendarUnit: .quarter, calendar: calendar))
		XCTAssertEqual(dateFromString("2015-01-01"), dateFromString("2015-01-01").drp_beginning(ofCalendarUnit: .quarter, calendar: calendar))
		
		XCTAssertEqual(dateFromString("2015-01-01"), dateFromString("2015-01-01").drp_beginning(ofCalendarUnit: .month, calendar: calendar))
		XCTAssertEqual(dateFromString("2015-12-01"), dateFromString("2015-12-31").drp_beginning(ofCalendarUnit: .month, calendar: calendar))
	}
	
	func testEndOfCalendarUnit() {
		XCTAssertEqual(dateFromStringWithTime("2015-12-31 23:59:59"), dateFromString("2015-01-01").drp_end(ofCalendarUnit: .year, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-12-31 23:59:59"), dateFromString("2015-12-31").drp_end(ofCalendarUnit: .year, calendar: calendar))
		
		XCTAssertEqual(dateFromStringWithTime("2015-12-31 23:59:59"), dateFromString("2015-12-31").drp_end(ofCalendarUnit: .quarter, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-12-31 23:59:59"), dateFromString("2015-10-01").drp_end(ofCalendarUnit: .quarter, calendar: calendar))
		
		XCTAssertEqual(dateFromStringWithTime("2015-01-31 23:59:59"), dateFromString("2015-01-01").drp_end(ofCalendarUnit: .month, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-12-31 23:59:59"), dateFromString("2015-12-31").drp_end(ofCalendarUnit: .month, calendar: calendar))
	}
	
	func testEndOfCalendarUnitWithoutAdjusting() {
		XCTAssertEqual(dateFromStringWithTime("2016-01-01 00:00:00"), dateFromString("2015-01-01").drp_end(ofCalendarUnit: .year, calendar: calendar, adjustByOneSecond: false))
		XCTAssertEqual(dateFromStringWithTime("2016-01-01 00:00:00"), dateFromString("2015-12-31").drp_end(ofCalendarUnit: .year, calendar: calendar, adjustByOneSecond: false))
		
		XCTAssertEqual(dateFromStringWithTime("2016-01-01 00:00:00"), dateFromString("2015-12-31").drp_end(ofCalendarUnit: .quarter, calendar: calendar, adjustByOneSecond: false))
		XCTAssertEqual(dateFromStringWithTime("2016-01-01 00:00:00"), dateFromString("2015-10-01").drp_end(ofCalendarUnit: .quarter, calendar: calendar, adjustByOneSecond: false))
		
		XCTAssertEqual(dateFromStringWithTime("2015-02-01 00:00:00"), dateFromString("2015-01-01").drp_end(ofCalendarUnit: .month, calendar: calendar, adjustByOneSecond: false))
		XCTAssertEqual(dateFromStringWithTime("2016-01-01 00:00:00"), dateFromString("2015-12-31").drp_end(ofCalendarUnit: .month, calendar: calendar, adjustByOneSecond: false))
	}
	
	func testAddingUnitsWithDST() {
		XCTAssertEqual(dateFromStringWithTime("2016-03-27 01:10:00"),
		               dateFromStringWithTime("2016-03-27 00:10:00").drp_addCalendarUnits(1, unit: .hour, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2016-03-27 03:10:00"),
		               dateFromStringWithTime("2016-03-27 01:10:00").drp_addCalendarUnits(1, unit: .hour, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2016-03-27 04:10:00"),
		               dateFromStringWithTime("2016-03-27 03:10:00").drp_addCalendarUnits(1, unit: .hour, calendar: calendar))
		
		XCTAssertEqual(dateFromStringWithTime("2016-03-27 00:10:00"),
		               dateFromStringWithTime("2016-03-27 01:10:00").drp_addCalendarUnits(-1, unit: .hour, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2016-03-27 01:10:00"),
		               dateFromStringWithTime("2016-03-27 03:10:00").drp_addCalendarUnits(-1, unit: .hour, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2016-03-27 03:10:00"),
		               dateFromStringWithTime("2016-03-27 04:10:00").drp_addCalendarUnits(-1, unit: .hour, calendar: calendar))
		
		
		XCTAssertEqual(dateFromStringWithTime("2016-10-30 01:10:00"),
		               dateFromStringWithTime("2016-10-30 00:10:00").drp_addCalendarUnits(1, unit: .hour, calendar: calendar))
		XCTAssertEqual(isoDate("2016-10-30T00:10:00.000Z"),
		               dateFromStringWithTime("2016-10-30 01:10:00").drp_addCalendarUnits(1, unit: .hour, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2016-10-30 04:10:00"),
		               dateFromStringWithTime("2016-10-30 03:10:00").drp_addCalendarUnits(1, unit: .hour, calendar: calendar))
		
		XCTAssertEqual(dateFromStringWithTime("2016-10-30 00:10:00"),
		               dateFromStringWithTime("2016-10-30 01:10:00").drp_addCalendarUnits(-1, unit: .hour, calendar: calendar))
		XCTAssertEqual(isoDate("2016-10-30T01:10:00.000Z"),
		               dateFromStringWithTime("2016-10-30 03:10:00").drp_addCalendarUnits(-1, unit: .hour, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2016-10-30 03:10:00"),
		               dateFromStringWithTime("2016-10-30 04:10:00").drp_addCalendarUnits(-1, unit: .hour, calendar: calendar))
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
