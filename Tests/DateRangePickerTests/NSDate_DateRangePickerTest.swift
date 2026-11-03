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
	
	func testEndOfCalendarUnitInOtherTimeZone() {
		var kiritimatiCalendar = Calendar(identifier: .gregorian)
		kiritimatiCalendar.timeZone = TimeZone(identifier: "Pacific/Kiritimati")!
		
		// 12:00 UTC on June 3rd is 02:00 on June 4th in Kiritimati (UTC+14).
		XCTAssertEqual(isoDate("2015-06-04T09:59:59.000Z"),
		               isoDate("2015-06-03T12:00:00.000Z").drp_end(ofCalendarUnit: .day, calendar: kiritimatiCalendar))
		XCTAssertEqual(isoDate("2015-06-04T10:00:00.000Z"),
		               isoDate("2015-06-03T12:00:00.000Z").drp_end(of: .day, calendar: kiritimatiCalendar))
	}
	
	/// America/Havana skips midnight on 8 March 2026 (00:00 becomes 01:00), so that day and the week it starts begin at
	/// 01:00, while the next day and week begin at 00:00 again. One unit after the start would end them an hour late.
	func testEndOfUnitThatBeginsAfterASkippedMidnight() {
		var havanaCalendar = Calendar(identifier: .gregorian)
		havanaCalendar.timeZone = TimeZone(identifier: "America/Havana")!
		havanaCalendar.firstWeekday = 1
		let noon = isoDate("2026-03-08T17:00:00.000Z")

		XCTAssertEqual(isoDate("2026-03-08T05:00:00.000Z"), noon.drp_beginning(of: .day, calendar: havanaCalendar))
		XCTAssertEqual(isoDate("2026-03-09T04:00:00.000Z"), noon.drp_end(of: .day, calendar: havanaCalendar))
		XCTAssertEqual(isoDate("2026-03-09T04:00:00.000Z"), noon.drp_end(of: .day, hourShift: 0, calendar: havanaCalendar))
		XCTAssertEqual(isoDate("2026-03-09T03:59:59.000Z"), noon.drp_end(ofCalendarUnit: .day, calendar: havanaCalendar))
		XCTAssertEqual(isoDate("2026-03-09T04:00:00.000Z"),
		               noon.drp_end(ofCalendarUnit: .day, calendar: havanaCalendar, adjustByOneSecond: false))

		XCTAssertEqual(isoDate("2026-03-15T04:00:00.000Z"), noon.drp_end(of: .weekOfYear, calendar: havanaCalendar))
		XCTAssertEqual(isoDate("2026-03-15T04:00:00.000Z"), noon.drp_end(of: .weekOfYear, hourShift: 0, calendar: havanaCalendar))
		XCTAssertEqual(isoDate("2026-03-15T03:59:59.000Z"), noon.drp_end(ofCalendarUnit: .weekOfYear, calendar: havanaCalendar))

		// The day before ends where March 8 begins, at 01:00 local time.
		let dayBefore = isoDate("2026-03-07T17:00:00.000Z")
		XCTAssertEqual(isoDate("2026-03-08T05:00:00.000Z"), dayBefore.drp_end(of: .day, calendar: havanaCalendar))
		XCTAssertEqual(isoDate("2026-03-08T05:00:00.000Z"), dayBefore.drp_end(of: .day, hourShift: 0, calendar: havanaCalendar))
	}

	/// Australia/Lord_Howe shifts by 30 minutes, where looking up the beginning of the next unit can overshoot or come
	/// out before the input. The end then stays one unit after the beginning, as before.
	func testEndOfUnitAtAThirtyMinuteShift() {
		var lordHoweCalendar = Calendar(identifier: .gregorian)
		lordHoweCalendar.timeZone = TimeZone(identifier: "Australia/Lord_Howe")!

		// 3 October 2027 skips 02:00 to 02:30, so its days with an hour shift of 2 begin at 02:30. Noon on 2 October
		// belongs to the day that ends there, not to one that ends a day later.
		XCTAssertEqual(isoDate("2027-10-02T15:30:00.000Z"),
		               isoDate("2027-10-02T01:30:00.000Z").drp_end(of: .day, hourShift: 2, calendar: lordHoweCalendar))

		// 5 April 2015 repeats 01:30 to 02:00. An instant in the first pass ends its hour at the end of the first pass.
		XCTAssertEqual(isoDate("2015-04-04T15:00:00.000Z"),
		               isoDate("2015-04-04T14:48:53.000Z").drp_end(ofCalendarUnit: .hour, calendar: lordHoweCalendar,
		                                                           adjustByOneSecond: false))
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
	
	func testEndOfCalendarComponent() {
		XCTAssertEqual(dateFromStringWithTime("2016-01-01 00:00:00"), dateFromString("2015-01-01").drp_end(of: .year, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2016-01-01 00:00:00"), dateFromString("2015-12-31").drp_end(of: .year, calendar: calendar))
		
		XCTAssertEqual(dateFromStringWithTime("2016-01-01 00:00:00"), dateFromString("2015-12-31").drp_end(of: .quarter, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2016-01-01 00:00:00"), dateFromString("2015-10-01").drp_end(of: .quarter, calendar: calendar))
		
		XCTAssertEqual(dateFromStringWithTime("2015-02-01 00:00:00"), dateFromString("2015-01-01").drp_end(of: .month, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2016-01-01 00:00:00"), dateFromString("2015-12-31").drp_end(of: .month, calendar: calendar))
	}
	
	func testEndOfCalendarComponentWithoutReturningNext() {
		XCTAssertEqual(dateFromStringWithTime("2016-01-01 00:00:00"),
		               dateFromString("2016-01-01").drp_end(of: .year, calendar: calendar, returnNextIfAtBoundary: false))
		XCTAssertEqual(dateFromStringWithTime("2016-01-01 00:00:00"),
		               dateFromString("2015-12-31").drp_end(of: .year, calendar: calendar, returnNextIfAtBoundary: false))
		
		XCTAssertEqual(dateFromStringWithTime("2016-01-01 00:00:00"),
		               dateFromString("2015-12-31").drp_end(of: .quarter, calendar: calendar, returnNextIfAtBoundary: false))
		XCTAssertEqual(dateFromStringWithTime("2015-10-01 00:00:00"),
		               dateFromString("2015-10-01").drp_end(of: .quarter, calendar: calendar, returnNextIfAtBoundary: false))
		
		XCTAssertEqual(dateFromStringWithTime("2015-01-01 00:00:00"),
		               dateFromString("2015-01-01").drp_end(of: .month, calendar: calendar, returnNextIfAtBoundary: false))
		XCTAssertEqual(dateFromStringWithTime("2016-01-01 00:00:00"),
		               dateFromString("2015-12-31").drp_end(of: .month, calendar: calendar, returnNextIfAtBoundary: false))
	}
	
	func testSettingHour() {
		XCTAssertEqual(dateFromStringWithTime("2017-01-23 05:00:00"),
		               dateFromStringWithTime("2017-01-23 00:01:02").drp_settingHour(to: 5, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2017-01-23 05:00:00"),
		               dateFromStringWithTime("2017-01-23 00:01:02")
						.addingTimeInterval(0.1)
						.drp_settingHour(to: 5, calendar: calendar))
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
	
	func testEndOfShiftedCalendarComponent() {
		XCTAssertEqual(dateFromStringWithTime("2015-01-01 05:00:00"),
		               dateFromStringWithTime("2015-01-01 00:00:00").drp_end(of: .year, hourShift: 5, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-01-01 05:00:00"),
		               dateFromStringWithTime("2015-01-01 04:59:59").drp_end(of: .year, hourShift: 5, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2016-01-01 05:00:00"),
		               dateFromStringWithTime("2015-01-01 05:00:00").drp_end(of: .year, hourShift: 5, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2016-01-01 05:00:00"),
		               dateFromStringWithTime("2015-01-01 05:00:01").drp_end(of: .year, hourShift: 5, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2016-01-01 05:00:00"),
		               dateFromStringWithTime("2015-12-31 00:00:00").drp_end(of: .year, hourShift: 5, calendar: calendar))
		
		
		XCTAssertEqual(dateFromStringWithTime("2015-01-01 05:00:00"),
		               dateFromStringWithTime("2015-01-01 00:00:00").drp_end(of: .month, hourShift: 5, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-01-01 05:00:00"),
		               dateFromStringWithTime("2015-01-01 04:59:59").drp_end(of: .month, hourShift: 5, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-02-01 05:00:00"),
		               dateFromStringWithTime("2015-01-01 05:00:00").drp_end(of: .month, hourShift: 5, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-02-01 05:00:00"),
		               dateFromStringWithTime("2015-01-01 05:00:01").drp_end(of: .month, hourShift: 5, calendar: calendar))
		
		XCTAssertEqual(dateFromStringWithTime("2015-02-01 05:00:00"),
		               dateFromStringWithTime("2015-02-01 00:00:00").drp_end(of: .month, hourShift: 5, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-02-01 05:00:00"),
		               dateFromStringWithTime("2015-02-01 04:59:59").drp_end(of: .month, hourShift: 5, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-03-01 05:00:00"),
		               dateFromStringWithTime("2015-02-01 05:00:00").drp_end(of: .month, hourShift: 5, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-03-01 05:00:00"),
		               dateFromStringWithTime("2015-02-01 05:00:01").drp_end(of: .month, hourShift: 5, calendar: calendar))
		
		XCTAssertEqual(dateFromStringWithTime("2016-01-01 05:00:00"),
		               dateFromStringWithTime("2015-12-31 00:00:00").drp_end(of: .month, hourShift: 5, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2016-01-01 05:00:00"),
		               dateFromStringWithTime("2015-12-31 04:59:59").drp_end(of: .month, hourShift: 5, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2016-01-01 05:00:00"),
		               dateFromStringWithTime("2015-12-31 05:00:00").drp_end(of: .month, hourShift: 5, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2016-01-01 05:00:00"),
		               dateFromStringWithTime("2015-12-31 05:00:01").drp_end(of: .month, hourShift: 5, calendar: calendar))
		
		
		XCTAssertEqual(dateFromStringWithTime("2015-01-05 05:00:00"),
		               dateFromStringWithTime("2015-01-05 00:00:00").drp_end(of: .weekOfYear, hourShift: 5, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-01-05 05:00:00"),
		               dateFromStringWithTime("2015-01-05 04:59:59").drp_end(of: .weekOfYear, hourShift: 5, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-01-12 05:00:00"),
		               dateFromStringWithTime("2015-01-05 05:00:00").drp_end(of: .weekOfYear, hourShift: 5, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-01-12 05:00:00"),
		               dateFromStringWithTime("2015-01-05 05:00:01").drp_end(of: .weekOfYear, hourShift: 5, calendar: calendar))
		
		XCTAssertEqual(dateFromStringWithTime("2015-01-12 05:00:00"),
		               dateFromStringWithTime("2015-01-12 00:00:00").drp_end(of: .weekOfYear, hourShift: 5, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-01-12 05:00:00"),
		               dateFromStringWithTime("2015-01-12 04:59:59").drp_end(of: .weekOfYear, hourShift: 5, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-01-19 05:00:00"),
		               dateFromStringWithTime("2015-01-12 05:00:00").drp_end(of: .weekOfYear, hourShift: 5, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-01-19 05:00:00"),
		               dateFromStringWithTime("2015-01-12 05:00:01").drp_end(of: .weekOfYear, hourShift: 5, calendar: calendar))
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
	
	func testEndOfShiftedCalendarComponentForUnaffectedComponents() {
		XCTAssertEqual(dateFromStringWithTime("2015-01-12 05:00:00"),
		               dateFromStringWithTime("2015-01-12 04:06:07").drp_end(of: .hour, hourShift: 0, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-01-12 04:07:00"),
		               dateFromStringWithTime("2015-01-12 04:06:07").drp_end(of: .minute, hourShift: 0, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-01-12 04:06:08"),
		               dateFromStringWithTime("2015-01-12 04:06:07").drp_end(of: .second, hourShift: 0, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-01-12 06:00:00"),
		               dateFromStringWithTime("2015-01-12 05:06:07").drp_end(of: .hour, hourShift: 0, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-01-12 05:07:00"),
		               dateFromStringWithTime("2015-01-12 05:06:07").drp_end(of: .minute, hourShift: 0, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-01-12 05:06:08"),
		               dateFromStringWithTime("2015-01-12 05:06:07").drp_end(of: .second, hourShift: 0, calendar: calendar))
		
		XCTAssertEqual(dateFromStringWithTime("2015-01-12 05:00:00"),
		               dateFromStringWithTime("2015-01-12 04:06:07").drp_end(of: .hour, hourShift: 5, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-01-12 04:07:00"),
		               dateFromStringWithTime("2015-01-12 04:06:07").drp_end(of: .minute, hourShift: 5, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-01-12 04:06:08"),
		               dateFromStringWithTime("2015-01-12 04:06:07").drp_end(of: .second, hourShift: 5, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-01-12 06:00:00"),
		               dateFromStringWithTime("2015-01-12 05:06:07").drp_end(of: .hour, hourShift: 5, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-01-12 05:07:00"),
		               dateFromStringWithTime("2015-01-12 05:06:07").drp_end(of: .minute, hourShift: 5, calendar: calendar))
		XCTAssertEqual(dateFromStringWithTime("2015-01-12 05:06:08"),
		               dateFromStringWithTime("2015-01-12 05:06:07").drp_end(of: .second, hourShift: 5, calendar: calendar))
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
	
	// MARK: - Hour shift 0
	
	private func calendar(inTimeZone identifier: String) -> Calendar {
		var calendar = Calendar(identifier: .gregorian)
		calendar.locale = Locale(identifier: "en_DE")
		calendar.timeZone = TimeZone(identifier: identifier)!
		return calendar
	}
	
	// What `drp_beginning(of:hourShift:calendar:)` does for a nonzero shift.
	private func beginningThroughShiftedDay(_ date: Date, of component: Calendar.Component, hourShift: Int,
	                                        calendar: Calendar) -> Date? {
		return date
			.drp_beginningOfShiftedDay(by: hourShift, calendar: calendar)?
			.drp_beginning(of: component, calendar: calendar)?
			.drp_settingHour(to: hourShift, calendar: calendar)
	}
	
	// Walks four days around `day`, so that both sides of a transition on that day are covered.
	private func assertHourShiftZeroMatchesShiftedDayPath(_ timeZone: String, around day: String,
	                                                      file: StaticString = #filePath, line: UInt = #line) {
		let calendar = self.calendar(inTimeZone: timeZone)
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd HH:mm"
		formatter.locale = Locale(identifier: "en_US_POSIX")
		formatter.timeZone = TimeZone(secondsFromGMT: 0)
		let start = formatter.date(from: day + " 12:00")!.addingTimeInterval(-2 * 86400)
		for minutes in stride(from: 0, to: 4 * 24 * 60, by: 45) {
			let date = start.addingTimeInterval(TimeInterval(minutes * 60))
			for component: Calendar.Component in [.day, .weekOfYear, .month, .quarter, .year] {
				let expected = beginningThroughShiftedDay(date, of: component, hourShift: 0, calendar: calendar)
				XCTAssertEqual(expected, date.drp_beginning(of: component, hourShift: 0, calendar: calendar),
				               "\(timeZone), \(component), \(date)", file: file, line: line)
				XCTAssertEqual(expected?.drp_adding(1, component: component, calendar: calendar),
				               date.drp_end(of: component, hourShift: 0, calendar: calendar),
				               "\(timeZone), \(component), \(date)", file: file, line: line)
			}
		}
	}
	
	func testHourShiftZeroOnPlainDays() {
		assertHourShiftZeroMatchesShiftedDayPath("Europe/Berlin", around: "2025-06-18")
		assertHourShiftZeroMatchesShiftedDayPath("Europe/Berlin", around: "2025-01-01")
		assertHourShiftZeroMatchesShiftedDayPath("America/Havana", around: "2025-06-30")
		assertHourShiftZeroMatchesShiftedDayPath("Pacific/Kiritimati", around: "2025-12-31")
	}
	
	func testHourShiftZeroAcrossDaylightSavingTransitions() {
		// The clocks change during the night, away from midnight.
		assertHourShiftZeroMatchesShiftedDayPath("Europe/Berlin", around: "2025-03-30")
		assertHourShiftZeroMatchesShiftedDayPath("Europe/Berlin", around: "2025-10-26")
		assertHourShiftZeroMatchesShiftedDayPath("America/New_York", around: "2025-03-09")
		assertHourShiftZeroMatchesShiftedDayPath("America/New_York", around: "2025-11-02")
		
		// The clocks go back across midnight: Havana repeats the hour after it, the others the hour before it.
		assertHourShiftZeroMatchesShiftedDayPath("America/Havana", around: "2025-11-02")
		assertHourShiftZeroMatchesShiftedDayPath("Asia/Beirut", around: "2025-10-26")
		assertHourShiftZeroMatchesShiftedDayPath("Africa/Cairo", around: "2025-10-31")
		assertHourShiftZeroMatchesShiftedDayPath("America/Santiago", around: "2025-04-06")
	}
	
	func testHourShiftZeroWhenDaylightSavingTimeSkipsMidnight() {
		// Each of these days starts at 01:00.
		let days: [(timeZone: String, day: String, start: TimeInterval)] = [
			("America/Havana", "2025-03-09", 1741496400), // 05:00 UTC
			("Asia/Beirut", "2025-03-30", 1743285600), // 22:00 UTC the day before
			("Africa/Cairo", "2025-04-25", 1745532000), // 22:00 UTC the day before
			("America/Santiago", "2025-09-07", 1757217600), // 04:00 UTC
		]
		for (timeZone, day, start) in days {
			let calendar = self.calendar(inTimeZone: timeZone)
			let dayStart = Date(timeIntervalSince1970: start)
			XCTAssertEqual(1, calendar.component(.hour, from: dayStart), timeZone)
			XCTAssertEqual(dayStart, calendar.startOfDay(for: dayStart), timeZone)
			
			assertHourShiftZeroMatchesShiftedDayPath(timeZone, around: day)
			let noon = dayStart.addingTimeInterval(11 * 3600)
			XCTAssertEqual(dayStart, dayStart.drp_beginning(of: .day, hourShift: 0, calendar: calendar), timeZone)
			XCTAssertEqual(dayStart, noon.drp_beginning(of: .day, hourShift: 0, calendar: calendar), timeZone)
		}
	}
	
	func testNonzeroHourShiftOnADayThatSkipsMidnight() {
		let calendar = self.calendar(inTimeZone: "America/Havana")
		// 2025-03-09 05:00 local time, which is 09:00 UTC. The day before lost no hour.
		let shiftedDayStart = Date(timeIntervalSince1970: 1741510800)
		let beforeShift = shiftedDayStart.addingTimeInterval(-1)
		let afterShift = shiftedDayStart.addingTimeInterval(1)
		
		XCTAssertEqual(shiftedDayStart, afterShift.drp_beginning(of: .day, hourShift: 5, calendar: calendar))
		XCTAssertEqual(shiftedDayStart.addingTimeInterval(-23 * 3600),
		               beforeShift.drp_beginning(of: .day, hourShift: 5, calendar: calendar))
		for date in [beforeShift, shiftedDayStart, afterShift] {
			for component: Calendar.Component in [.day, .weekOfYear, .month, .quarter, .year] {
				XCTAssertEqual(beginningThroughShiftedDay(date, of: component, hourShift: 5, calendar: calendar),
				               date.drp_beginning(of: component, hourShift: 5, calendar: calendar))
			}
		}
	}
}
