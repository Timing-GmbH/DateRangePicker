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
	
	func testCalendarUnitsSince() {
		XCTAssertEqual(56, dateFromString("2015-07-10").drp_calendarUnits(since: dateFromString("2015-05-15"), unit: .day, calendar: calendar))
		XCTAssertEqual(8, dateFromString("2015-07-10").drp_calendarUnits(since: dateFromString("2015-05-15"), unit: .weekOfYear, calendar: calendar))
		XCTAssertEqual(2, dateFromString("2015-07-10").drp_calendarUnits(since: dateFromString("2015-05-15"), unit: .month, calendar: calendar))
		XCTAssertEqual(0, dateFromString("2015-07-10").drp_calendarUnits(since: dateFromString("2015-05-15"), unit: .quarter, calendar: calendar))
		XCTAssertEqual(0, dateFromString("2015-07-10").drp_calendarUnits(since: dateFromString("2015-05-15"), unit: .year, calendar: calendar))
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
	
	func testEndOfCalendarUnitWithoutReturningNext() {
		XCTAssertEqual(dateFromStringWithTime("2016-01-01 00:00:00"),
		               dateFromString("2016-01-01").drp_end(ofCalendarUnit: .year, calendar: calendar, adjustByOneSecond: false, returnNextIfAtBoundary: false))
		XCTAssertEqual(dateFromStringWithTime("2016-01-01 00:00:00"),
		               dateFromString("2015-12-31").drp_end(ofCalendarUnit: .year, calendar: calendar, adjustByOneSecond: false, returnNextIfAtBoundary: false))
		
		XCTAssertEqual(dateFromStringWithTime("2016-01-01 00:00:00"),
		               dateFromString("2015-12-31").drp_end(ofCalendarUnit: .quarter, calendar: calendar, adjustByOneSecond: false, returnNextIfAtBoundary: false))
		XCTAssertEqual(dateFromStringWithTime("2015-10-01 00:00:00"),
		               dateFromString("2015-10-01").drp_end(ofCalendarUnit: .quarter, calendar: calendar, adjustByOneSecond: false, returnNextIfAtBoundary: false))
		
		XCTAssertEqual(dateFromStringWithTime("2015-01-01 00:00:00"),
		               dateFromString("2015-01-01").drp_end(ofCalendarUnit: .month, calendar: calendar, adjustByOneSecond: false, returnNextIfAtBoundary: false))
		XCTAssertEqual(dateFromStringWithTime("2016-01-01 00:00:00"),
		               dateFromString("2015-12-31").drp_end(ofCalendarUnit: .month, calendar: calendar, adjustByOneSecond: false, returnNextIfAtBoundary: false))
	}
	
	func testAddingHoursWithDST() {
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
		
		
		XCTAssertEqual(isoDate("2016-10-30T00:10:00.000Z"),
		               isoDate("2016-10-29T23:10:00.000Z").drp_addCalendarUnits(1, unit: .hour, calendar: calendar))
		XCTAssertEqual(isoDate("2016-10-30T01:10:00.000Z"),
		               isoDate("2016-10-30T00:10:00.000Z").drp_addCalendarUnits(1, unit: .hour, calendar: calendar))
		XCTAssertEqual(isoDate("2016-10-30T02:10:00.000Z"),
		               isoDate("2016-10-30T01:10:00.000Z").drp_addCalendarUnits(1, unit: .hour, calendar: calendar))
		XCTAssertEqual(isoDate("2016-10-30T03:10:00.000Z"),
		               isoDate("2016-10-30T02:10:00.000Z").drp_addCalendarUnits(1, unit: .hour, calendar: calendar))
		
		
		XCTAssertEqual(isoDate("2016-10-29T23:10:00.000Z"),
		               isoDate("2016-10-30T00:10:00.000Z").drp_addCalendarUnits(-1, unit: .hour, calendar: calendar))
		XCTAssertEqual(isoDate("2016-10-30T00:10:00.000Z"),
		               isoDate("2016-10-30T01:10:00.000Z").drp_addCalendarUnits(-1, unit: .hour, calendar: calendar))
		XCTAssertEqual(isoDate("2016-10-30T01:10:00.000Z"),
		               isoDate("2016-10-30T02:10:00.000Z").drp_addCalendarUnits(-1, unit: .hour, calendar: calendar))
		XCTAssertEqual(isoDate("2016-10-30T02:10:00.000Z"),
		               isoDate("2016-10-30T03:10:00.000Z").drp_addCalendarUnits(-1, unit: .hour, calendar: calendar))
	}
	
	func testAddingDaysWithDST() {
		XCTAssertEqual(dateFromStringWithTime("2016-03-27 01:10:00"),
		               dateFromStringWithTime("2016-03-26 01:10:00").drp_addCalendarUnits(1, unit: .day, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2016-03-27 02:10:00"),
		               dateFromStringWithTime("2016-03-26 02:10:00").drp_addCalendarUnits(1, unit: .day, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2016-03-27 03:10:00"),
		               dateFromStringWithTime("2016-03-26 03:10:00").drp_addCalendarUnits(1, unit: .day, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2016-03-27 04:10:00"),
		               dateFromStringWithTime("2016-03-26 04:10:00").drp_addCalendarUnits(1, unit: .day, calendar: calendar))
		
		XCTAssertEqual(dateFromStringWithTime("2016-10-30 01:10:00"),
		               dateFromStringWithTime("2016-10-29 01:10:00").drp_addCalendarUnits(1, unit: .day, calendar: calendar))
		XCTAssertEqual(isoDate("2016-10-30T00:10:00.000Z"),
		               dateFromStringWithTime("2016-10-29 02:10:00").drp_addCalendarUnits(1, unit: .day, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2016-10-30 03:10:00"),
		               dateFromStringWithTime("2016-10-29 03:10:00").drp_addCalendarUnits(1, unit: .day, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2016-10-30 04:10:00"),
		               dateFromStringWithTime("2016-10-29 04:10:00").drp_addCalendarUnits(1, unit: .day, calendar: calendar))
	}
}

extension Date_DateRangePickerTest {
	func testAddingCalendarComponents() {
		XCTAssertEqual(dateFromString("2022-06-03"), dateFromString("2015-06-03").drp_adding(7, component: .year, calendar: calendar))
		XCTAssertEqual(dateFromString("2008-06-03"), dateFromString("2015-06-03").drp_adding(-7, component: .year, calendar: calendar))
		
		XCTAssertEqual(dateFromString("2017-03-03"), dateFromString("2015-06-03").drp_adding(7, component: .quarter, calendar: calendar))
		XCTAssertEqual(dateFromString("2013-09-03"), dateFromString("2015-06-03").drp_adding(-7, component: .quarter, calendar: calendar))
		
		XCTAssertEqual(dateFromString("2016-01-03"), dateFromString("2015-06-03").drp_adding(7, component: .month, calendar: calendar))
		XCTAssertEqual(dateFromString("2014-11-03"), dateFromString("2015-06-03").drp_adding(-7, component: .month, calendar: calendar))
		
		XCTAssertEqual(dateFromString("2015-06-10"), dateFromString("2015-06-03").drp_adding(7, component: .day, calendar: calendar))
		XCTAssertEqual(dateFromString("2015-05-27"), dateFromString("2015-06-03").drp_adding(-7, component: .day, calendar: calendar))
		
		XCTAssertEqual(dateFromString("2016-01-06"), dateFromString("2015-12-30").drp_adding(7, component: .day, calendar: calendar))
	}
	
	func testBeginningOfCalendarComponent() {
		XCTAssertEqual(dateFromString("2015-01-01"), dateFromString("2015-01-01").drp_beginning(of: .year, calendar: calendar))
		XCTAssertEqual(dateFromString("2015-01-01"), dateFromString("2015-12-31").drp_beginning(of: .year, calendar: calendar))
		
		XCTAssertEqual(dateFromString("2015-04-01"), dateFromString("2015-06-03").drp_beginning(of: .quarter, calendar: calendar))
		XCTAssertEqual(dateFromString("2015-01-01"), dateFromString("2015-03-31").drp_beginning(of: .quarter, calendar: calendar))
		XCTAssertEqual(dateFromString("2015-10-01"), dateFromString("2015-10-01").drp_beginning(of: .quarter, calendar: calendar))
		XCTAssertEqual(dateFromString("2015-01-01"), dateFromString("2015-01-01").drp_beginning(of: .quarter, calendar: calendar))
		
		XCTAssertEqual(dateFromString("2015-01-01"), dateFromString("2015-01-01").drp_beginning(of: .month, calendar: calendar))
		XCTAssertEqual(dateFromString("2015-12-01"), dateFromString("2015-12-31").drp_beginning(of: .month, calendar: calendar))
	}
	
	func testSettingHour() {
		XCTAssertEqual(dateFromStringWithTime("2017-01-23 05:00:00"),
		               dateFromStringWithTime("2017-01-23 00:01:02").drp_settingHour(to: 5, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2017-01-23 05:00:00"),
		               dateFromStringWithTime("2017-01-23 01:01:02").drp_settingHour(to: 5, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2017-01-23 05:00:00"),
		               dateFromStringWithTime("2017-01-23 05:00:00").drp_settingHour(to: 5, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2017-01-23 05:00:00"),
		               dateFromStringWithTime("2017-01-23 05:01:02").drp_settingHour(to: 5, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2017-01-23 05:00:00"),
		               dateFromStringWithTime("2017-01-23 06:01:02").drp_settingHour(to: 5, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2017-01-23 05:00:00"),
		               dateFromStringWithTime("2017-01-23 23:01:02").drp_settingHour(to: 5, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2017-01-24 05:00:00"),
		               dateFromStringWithTime("2017-01-24 00:01:02").drp_settingHour(to: 5, calendar: calendar))
	}
	
	func testBeginningOfShiftedDay() {
		XCTAssertEqual(dateFromStringWithTime("2017-01-23 00:00:00"),
		               dateFromStringWithTime("2017-01-23 00:00:00").drp_beginningOfShiftedDay(by: 0, calendar: calendar))
		
		XCTAssertEqual(dateFromStringWithTime("2017-01-22 05:00:00"),
		               dateFromStringWithTime("2017-01-23 00:01:02").drp_beginningOfShiftedDay(by: 5, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2017-01-22 05:00:00"),
		               dateFromStringWithTime("2017-01-23 04:01:02").drp_beginningOfShiftedDay(by: 5, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2017-01-22 05:00:00"),
		               dateFromStringWithTime("2017-01-23 04:59:59").drp_beginningOfShiftedDay(by: 5, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2017-01-22 05:00:00"),
		               dateFromStringWithTime("2017-01-23 05:00:00")
						.addingTimeInterval(-0.00001)
						.drp_beginningOfShiftedDay(by: 5, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2017-01-23 05:00:00"),
		               dateFromStringWithTime("2017-01-23 05:00:00").drp_beginningOfShiftedDay(by: 5, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2017-01-23 05:00:00"),
		               dateFromStringWithTime("2017-01-23 05:01:02").drp_beginningOfShiftedDay(by: 5, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2017-01-23 05:00:00"),
		               dateFromStringWithTime("2017-01-23 05:01:02").drp_beginningOfShiftedDay(by: 5, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2017-01-23 05:00:00"),
		               dateFromStringWithTime("2017-01-23 23:01:02").drp_beginningOfShiftedDay(by: 5, calendar: calendar))
	}
	
	func testBeginningOfNextShiftedDay() {
		XCTAssertEqual(dateFromStringWithTime("2017-01-24 00:00:00"),
		               dateFromStringWithTime("2017-01-23 00:00:00").drp_beginningOfNextShiftedDay(by: 0, calendar: calendar))
		
		XCTAssertEqual(dateFromStringWithTime("2017-01-23 05:00:00"),
		               dateFromStringWithTime("2017-01-23 00:01:02").drp_beginningOfNextShiftedDay(by: 5, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2017-01-23 05:00:00"),
		               dateFromStringWithTime("2017-01-23 04:01:02").drp_beginningOfNextShiftedDay(by: 5, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2017-01-23 05:00:00"),
		               dateFromStringWithTime("2017-01-23 04:59:59").drp_beginningOfNextShiftedDay(by: 5, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2017-01-23 05:00:00"),
		               dateFromStringWithTime("2017-01-23 05:00:00")
						.addingTimeInterval(-0.00001)
						.drp_beginningOfNextShiftedDay(by: 5, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2017-01-24 05:00:00"),
		               dateFromStringWithTime("2017-01-23 05:00:00").drp_beginningOfNextShiftedDay(by: 5, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2017-01-24 05:00:00"),
		               dateFromStringWithTime("2017-01-23 05:01:02").drp_beginningOfNextShiftedDay(by: 5, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2017-01-24 05:00:00"),
		               dateFromStringWithTime("2017-01-23 05:01:02").drp_beginningOfNextShiftedDay(by: 5, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2017-01-24 05:00:00"),
		               dateFromStringWithTime("2017-01-23 23:01:02").drp_beginningOfNextShiftedDay(by: 5, calendar: calendar))
	}
	
	func testBeginningOfShiftedCalendarComponent() {
		XCTAssertEqual(dateFromStringWithTime("2015-01-01 00:00:00"),
		               dateFromStringWithTime("2015-01-01 00:00:00").drp_beginning(of: .year, hourShift: 0, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-01-01 00:00:00"),
		               dateFromStringWithTime("2015-01-01 04:59:59").drp_beginning(of: .year, hourShift: 0, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-01-01 00:00:00"),
		               dateFromStringWithTime("2015-01-01 05:00:00").drp_beginning(of: .year, hourShift: 0, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-01-01 00:00:00"),
		               dateFromStringWithTime("2015-01-01 05:00:01").drp_beginning(of: .year, hourShift: 0, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-01-01 00:00:00"),
		               dateFromStringWithTime("2015-12-31 00:00:00").drp_beginning(of: .year, hourShift: 0, calendar: calendar))
		
		
		XCTAssertEqual(dateFromStringWithTime("2015-01-01 00:00:00"),
		               dateFromStringWithTime("2015-01-01 00:00:00").drp_beginning(of: .month, hourShift: 0, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-01-01 00:00:00"),
		               dateFromStringWithTime("2015-01-01 04:59:59").drp_beginning(of: .month, hourShift: 0, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-01-01 00:00:00"),
		               dateFromStringWithTime("2015-01-01 05:00:00").drp_beginning(of: .month, hourShift: 0, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-01-01 00:00:00"),
		               dateFromStringWithTime("2015-01-01 05:00:01").drp_beginning(of: .month, hourShift: 0, calendar: calendar))
		
		XCTAssertEqual(dateFromStringWithTime("2015-02-01 00:00:00"),
		               dateFromStringWithTime("2015-02-01 00:00:00").drp_beginning(of: .month, hourShift: 0, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-02-01 00:00:00"),
		               dateFromStringWithTime("2015-02-01 04:59:59").drp_beginning(of: .month, hourShift: 0, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-02-01 00:00:00"),
		               dateFromStringWithTime("2015-02-01 05:00:00").drp_beginning(of: .month, hourShift: 0, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-02-01 00:00:00"),
		               dateFromStringWithTime("2015-02-01 05:00:01").drp_beginning(of: .month, hourShift: 0, calendar: calendar))
		
		XCTAssertEqual(dateFromStringWithTime("2015-12-01 00:00:00"),
		               dateFromStringWithTime("2015-12-31 00:00:00").drp_beginning(of: .month, hourShift: 0, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-12-01 00:00:00"),
		               dateFromStringWithTime("2015-12-31 04:59:59").drp_beginning(of: .month, hourShift: 0, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-12-01 00:00:00"),
		               dateFromStringWithTime("2015-12-31 05:00:00").drp_beginning(of: .month, hourShift: 0, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-12-01 00:00:00"),
		               dateFromStringWithTime("2015-12-31 05:00:01").drp_beginning(of: .month, hourShift: 0, calendar: calendar))
		
		
		XCTAssertEqual(dateFromStringWithTime("2015-01-05 00:00:00"),
		               dateFromStringWithTime("2015-01-05 00:00:00").drp_beginning(of: .weekOfYear, hourShift: 0, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-01-05 00:00:00"),
		               dateFromStringWithTime("2015-01-05 04:59:59").drp_beginning(of: .weekOfYear, hourShift: 0, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-01-05 00:00:00"),
		               dateFromStringWithTime("2015-01-05 05:00:00").drp_beginning(of: .weekOfYear, hourShift: 0, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-01-05 00:00:00"),
		               dateFromStringWithTime("2015-01-05 05:00:01").drp_beginning(of: .weekOfYear, hourShift: 0, calendar: calendar))
		
		XCTAssertEqual(dateFromStringWithTime("2015-01-12 00:00:00"),
		               dateFromStringWithTime("2015-01-12 00:00:00").drp_beginning(of: .weekOfYear, hourShift: 0, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-01-12 00:00:00"),
		               dateFromStringWithTime("2015-01-12 04:59:59").drp_beginning(of: .weekOfYear, hourShift: 0, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-01-12 00:00:00"),
		               dateFromStringWithTime("2015-01-12 05:00:00").drp_beginning(of: .weekOfYear, hourShift: 0, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-01-12 00:00:00"),
		               dateFromStringWithTime("2015-01-12 05:00:01").drp_beginning(of: .weekOfYear, hourShift: 0, calendar: calendar))
		
		
		
		XCTAssertEqual(dateFromStringWithTime("2014-01-01 05:00:00"),
		               dateFromStringWithTime("2015-01-01 00:00:00").drp_beginning(of: .year, hourShift: 5, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2014-01-01 05:00:00"),
		               dateFromStringWithTime("2015-01-01 04:59:59").drp_beginning(of: .year, hourShift: 5, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-01-01 05:00:00"),
		               dateFromStringWithTime("2015-01-01 05:00:00").drp_beginning(of: .year, hourShift: 5, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-01-01 05:00:00"),
		               dateFromStringWithTime("2015-01-01 05:00:01").drp_beginning(of: .year, hourShift: 5, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-01-01 05:00:00"),
		               dateFromStringWithTime("2015-12-31 00:00:00").drp_beginning(of: .year, hourShift: 5, calendar: calendar))
		
		
		XCTAssertEqual(dateFromStringWithTime("2014-12-01 05:00:00"),
		               dateFromStringWithTime("2015-01-01 00:00:00").drp_beginning(of: .month, hourShift: 5, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2014-12-01 05:00:00"),
		               dateFromStringWithTime("2015-01-01 04:59:59").drp_beginning(of: .month, hourShift: 5, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-01-01 05:00:00"),
		               dateFromStringWithTime("2015-01-01 05:00:00").drp_beginning(of: .month, hourShift: 5, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-01-01 05:00:00"),
		               dateFromStringWithTime("2015-01-01 05:00:01").drp_beginning(of: .month, hourShift: 5, calendar: calendar))
		
		XCTAssertEqual(dateFromStringWithTime("2015-01-01 05:00:00"),
		               dateFromStringWithTime("2015-02-01 00:00:00").drp_beginning(of: .month, hourShift: 5, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-01-01 05:00:00"),
		               dateFromStringWithTime("2015-02-01 04:59:59").drp_beginning(of: .month, hourShift: 5, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-02-01 05:00:00"),
		               dateFromStringWithTime("2015-02-01 05:00:00").drp_beginning(of: .month, hourShift: 5, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-02-01 05:00:00"),
		               dateFromStringWithTime("2015-02-01 05:00:01").drp_beginning(of: .month, hourShift: 5, calendar: calendar))
		
		XCTAssertEqual(dateFromStringWithTime("2015-12-01 05:00:00"),
		               dateFromStringWithTime("2015-12-31 00:00:00").drp_beginning(of: .month, hourShift: 5, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-12-01 05:00:00"),
		               dateFromStringWithTime("2015-12-31 04:59:59").drp_beginning(of: .month, hourShift: 5, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-12-01 05:00:00"),
		               dateFromStringWithTime("2015-12-31 05:00:00").drp_beginning(of: .month, hourShift: 5, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-12-01 05:00:00"),
		               dateFromStringWithTime("2015-12-31 05:00:01").drp_beginning(of: .month, hourShift: 5, calendar: calendar))
		
		
		XCTAssertEqual(dateFromStringWithTime("2014-12-29 05:00:00"),
		               dateFromStringWithTime("2015-01-05 00:00:00").drp_beginning(of: .weekOfYear, hourShift: 5, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2014-12-29 05:00:00"),
		               dateFromStringWithTime("2015-01-05 04:59:59").drp_beginning(of: .weekOfYear, hourShift: 5, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-01-05 05:00:00"),
		               dateFromStringWithTime("2015-01-05 05:00:00").drp_beginning(of: .weekOfYear, hourShift: 5, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-01-05 05:00:00"),
		               dateFromStringWithTime("2015-01-05 05:00:01").drp_beginning(of: .weekOfYear, hourShift: 5, calendar: calendar))
		
		XCTAssertEqual(dateFromStringWithTime("2015-01-05 05:00:00"),
		               dateFromStringWithTime("2015-01-12 00:00:00").drp_beginning(of: .weekOfYear, hourShift: 5, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-01-05 05:00:00"),
		               dateFromStringWithTime("2015-01-12 04:59:59").drp_beginning(of: .weekOfYear, hourShift: 5, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-01-12 05:00:00"),
		               dateFromStringWithTime("2015-01-12 05:00:00").drp_beginning(of: .weekOfYear, hourShift: 5, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-01-12 05:00:00"),
		               dateFromStringWithTime("2015-01-12 05:00:01").drp_beginning(of: .weekOfYear, hourShift: 5, calendar: calendar))
	}
	
	func testBeginningOfShiftedCalendarComponentForUnaffectedComponents() {
		XCTAssertEqual(dateFromStringWithTime("2015-01-12 04:00:00"),
		               dateFromStringWithTime("2015-01-12 04:06:07").drp_beginning(of: .hour, hourShift: 0, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-01-12 04:06:00"),
		               dateFromStringWithTime("2015-01-12 04:06:07").drp_beginning(of: .minute, hourShift: 0, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-01-12 04:06:07"),
		               dateFromStringWithTime("2015-01-12 04:06:07").drp_beginning(of: .second, hourShift: 0, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-01-12 05:00:00"),
		               dateFromStringWithTime("2015-01-12 05:06:07").drp_beginning(of: .hour, hourShift: 0, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-01-12 05:06:00"),
		               dateFromStringWithTime("2015-01-12 05:06:07").drp_beginning(of: .minute, hourShift: 0, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-01-12 05:06:07"),
		               dateFromStringWithTime("2015-01-12 05:06:07").drp_beginning(of: .second, hourShift: 0, calendar: calendar))
		
		XCTAssertEqual(dateFromStringWithTime("2015-01-12 04:00:00"),
		               dateFromStringWithTime("2015-01-12 04:06:07").drp_beginning(of: .hour, hourShift: 5, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-01-12 04:06:00"),
		               dateFromStringWithTime("2015-01-12 04:06:07").drp_beginning(of: .minute, hourShift: 5, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-01-12 04:06:07"),
		               dateFromStringWithTime("2015-01-12 04:06:07").drp_beginning(of: .second, hourShift: 5, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-01-12 05:00:00"),
		               dateFromStringWithTime("2015-01-12 05:06:07").drp_beginning(of: .hour, hourShift: 5, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-01-12 05:06:00"),
		               dateFromStringWithTime("2015-01-12 05:06:07").drp_beginning(of: .minute, hourShift: 5, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-01-12 05:06:07"),
		               dateFromStringWithTime("2015-01-12 05:06:07").drp_beginning(of: .second, hourShift: 5, calendar: calendar))
	}
	
	func testDaysSinceWithComponent() {
		XCTAssertEqual(7, dateFromString("2015-06-10").drp_components(.day, since: dateFromString("2015-06-03"), calendar: calendar))
	}
	
	func testDaysSinceWithComponentAndDSTCalendar() {
		XCTAssertEqual(7, dateFromString("2015-10-27").drp_components(.day, since: dateFromString("2015-10-20"), calendar: calendar))
		XCTAssertEqual(-7, dateFromString("2015-10-20").drp_components(.day, since: dateFromString("2015-10-27"), calendar: calendar))
		
		XCTAssertEqual(0, calendar.timeZone.daylightSavingTimeOffset(for: dateFromString("2015-03-25")))
		XCTAssertEqual(3600, calendar.timeZone.daylightSavingTimeOffset(for: dateFromString("2015-04-01")))
		XCTAssertEqual(7, dateFromString("2015-04-01").drp_components(.day, since: dateFromString("2015-03-25"), calendar: calendar))
		XCTAssertEqual(-7, dateFromString("2015-03-25").drp_components(.day, since: dateFromString("2015-04-01"), calendar: calendar))
	}
	
	func testComponentsSince() {
		XCTAssertEqual(56, dateFromString("2015-07-10").drp_components(.day, since: dateFromString("2015-05-15"), calendar: calendar))
		XCTAssertEqual(8, dateFromString("2015-07-10").drp_components(.weekOfYear, since: dateFromString("2015-05-15"), calendar: calendar))
		XCTAssertEqual(2, dateFromString("2015-07-10").drp_components(.month, since: dateFromString("2015-05-15"), calendar: calendar))
		XCTAssertEqual(0, dateFromString("2015-07-10").drp_components(.quarter, since: dateFromString("2015-05-15"), calendar: calendar))
		XCTAssertEqual(0, dateFromString("2015-07-10").drp_components(.year, since: dateFromString("2015-05-15"), calendar: calendar))
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
