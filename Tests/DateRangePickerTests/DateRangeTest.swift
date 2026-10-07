//
//  DateRangeTest.swift
//  DateRangePicker
//
//  Created by Daniel Alm on 08.11.15.
//  Copyright © 2015 Daniel Alm. All rights reserved.
//

import XCTest
@testable import DateRangePicker

class DateRangeTest: XCTestCase {
	fileprivate let dateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd"
		return dateFormatter
	}()
	func dateFromString(_ dateString: String) -> Date {
		return dateFormatter.date(from: dateString)!
	}
	
	fileprivate let dateFormatterWithTime: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
		return dateFormatter
	}()
	func dateFromStringWithTime(_ dateString: String) -> Date {
		return dateFormatterWithTime.date(from: dateString)!
	}
	
	fileprivate let isoDateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
		dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
		return dateFormatter
	}()
	func isoDate(_ dateString: String) -> Date {
		return isoDateFormatter.date(from: dateString)!
	}
	
	// UTC+14, so that its days differ from those of the time zone the tests run in.
	let kiritimatiCalendar: Calendar = {
		var calendar = Calendar(identifier: .gregorian)
		calendar.timeZone = TimeZone(identifier: "Pacific/Kiritimati")!
		return calendar
	}()
	// June 4th, 02:00 in Kiritimati.
	var kiritimatiNow: Date { return isoDate("2015-06-03T12:00:00Z") }
	
	func testTitle() {
		XCTAssertEqual("Custom", DateRange.custom(Date(), Date(), hourShift: 0).title)
		
		XCTAssertEqual("Past 7 Days", DateRange.pastDays(7, hourShift: 0).title)
		
		XCTAssertEqual("This Quarter", DateRange.calendarUnit(0, .quarter, hourShift: 0).title)
	}
	
	func testStartEndDates() {
		let startDate = dateFromString("2015-06-15")
		let endDate = dateFromString("2015-06-17")
		
		var dateRange = DateRange.custom(startDate, endDate, hourShift: 0)
		XCTAssertEqual(startDate, dateRange.startDate)
		XCTAssertEqual(endDate.drp_end(ofCalendarUnit: .day), dateRange.endDate)
		
		// Being able to specify a reference date would be nicer for testability,
		// but then the API would likely get very unwieldy.
		dateRange = DateRange.pastDays(30, hourShift: 0)
		XCTAssertEqual(Date().drp_addCalendarUnits(-30, unit: .day)!.drp_beginning(ofCalendarUnit: .day), dateRange.startDate)
		XCTAssertEqual(Date().drp_end(ofCalendarUnit: .day), dateRange.endDate)
		
		dateRange = DateRange.calendarUnit(0, .quarter, hourShift: 0)
		XCTAssertEqual(Date().drp_beginning(ofCalendarUnit: .quarter), dateRange.startDate)
		XCTAssertEqual(Date().drp_end(ofCalendarUnit: .quarter), dateRange.endDate)
		
		dateRange = DateRange.calendarUnit(-1, .quarter, hourShift: 0)
		XCTAssertEqual(Date().drp_addCalendarUnits(-1, unit: .quarter)!.drp_beginning(ofCalendarUnit: .quarter), dateRange.startDate)
		XCTAssertEqual(Date().drp_addCalendarUnits(-1, unit: .quarter)!.drp_end(ofCalendarUnit: .quarter), dateRange.endDate)
		
		dateRange = DateRange.calendarUnit(1, .quarter, hourShift: 0)
		XCTAssertEqual(Date().drp_addCalendarUnits(1, unit: .quarter)!.drp_beginning(ofCalendarUnit: .quarter), dateRange.startDate)
		XCTAssertEqual(Date().drp_addCalendarUnits(1, unit: .quarter)!.drp_end(ofCalendarUnit: .quarter), dateRange.endDate)
	}
	
	func testStartEndDatesWithHourShift() {
		let startDate = dateFromStringWithTime("2015-06-01 12:00:00")
		let endDate = dateFromStringWithTime("2015-06-03 12:00:00")
		
		let nowBeforeShift = dateFromStringWithTime("2015-06-01 04:59:59")
		let nowAfterShift = dateFromStringWithTime("2015-06-01 05:00:00")
		
		var dateRange = DateRange.custom(startDate, endDate, hourShift: 5)
		XCTAssertEqual(dateFromStringWithTime("2015-06-01 00:00:00"), dateRange.startDate(now: nowBeforeShift))
		XCTAssertEqual(dateFromStringWithTime("2015-06-03 23:59:59"), dateRange.endDate(now: nowBeforeShift))
		XCTAssertEqual(dateFromStringWithTime("2015-06-01 00:00:00"), dateRange.startDate(now: nowAfterShift))
		XCTAssertEqual(dateFromStringWithTime("2015-06-03 23:59:59"), dateRange.endDate(now: nowAfterShift))
		
		dateRange = DateRange.pastDays(2, hourShift: 5)
		XCTAssertEqual(dateFromStringWithTime("2015-05-29 00:00:00"),
		               dateRange.startDate(now: nowBeforeShift))
		XCTAssertEqual(dateFromStringWithTime("2015-05-31 23:59:59"),
		               dateRange.endDate(now: nowBeforeShift))
		XCTAssertEqual(dateFromStringWithTime("2015-05-30 00:00:00"),
		               dateRange.startDate(now: nowAfterShift))
		XCTAssertEqual(dateFromStringWithTime("2015-06-01 23:59:59"),
		               dateRange.endDate(now: nowAfterShift))
		
		dateRange = DateRange.calendarUnit(0, .month, hourShift: 5)
		XCTAssertEqual(dateFromStringWithTime("2015-05-01 00:00:00"),
		               dateRange.startDate(now: nowBeforeShift))
		XCTAssertEqual(dateFromStringWithTime("2015-05-31 23:59:59"),
		               dateRange.endDate(now: nowBeforeShift))
		XCTAssertEqual(dateFromStringWithTime("2015-06-01 00:00:00"),
		               dateRange.startDate(now: nowAfterShift))
		XCTAssertEqual(dateFromStringWithTime("2015-06-30 23:59:59"),
		               dateRange.endDate(now: nowAfterShift))
		
		dateRange = DateRange.calendarUnit(-1, .month, hourShift: 5)
		XCTAssertEqual(dateFromStringWithTime("2015-04-01 00:00:00"),
		               dateRange.startDate(now: nowBeforeShift))
		XCTAssertEqual(dateFromStringWithTime("2015-04-30 23:59:59"),
		               dateRange.endDate(now: nowBeforeShift))
		XCTAssertEqual(dateFromStringWithTime("2015-05-01 00:00:00"),
		               dateRange.startDate(now: nowAfterShift))
		XCTAssertEqual(dateFromStringWithTime("2015-05-31 23:59:59"),
		               dateRange.endDate(now: nowAfterShift))
		
		dateRange = DateRange.calendarUnit(1, .month, hourShift: 5)
		XCTAssertEqual(dateFromStringWithTime("2015-06-01 00:00:00"),
		               dateRange.startDate(now: nowBeforeShift))
		XCTAssertEqual(dateFromStringWithTime("2015-06-30 23:59:59"),
		               dateRange.endDate(now: nowBeforeShift))
		XCTAssertEqual(dateFromStringWithTime("2015-07-01 00:00:00"),
		               dateRange.startDate(now: nowAfterShift))
		XCTAssertEqual(dateFromStringWithTime("2015-07-31 23:59:59"),
		               dateRange.endDate(now: nowAfterShift))
	}
	
	func testStartEndDatesWithNowAndCalendar() {
		var dateRange = DateRange.custom(isoDate("2015-06-02T12:00:00Z"), isoDate("2015-06-03T12:00:00Z"), hourShift: 0)
		XCTAssertEqual(isoDate("2015-06-02T10:00:00Z"), dateRange.startDate(now: kiritimatiNow, calendar: kiritimatiCalendar))
		XCTAssertEqual(isoDate("2015-06-04T09:59:59Z"), dateRange.endDate(now: kiritimatiNow, calendar: kiritimatiCalendar))
		
		dateRange = DateRange.pastDays(2, hourShift: 0)
		XCTAssertEqual(isoDate("2015-06-01T10:00:00Z"), dateRange.startDate(now: kiritimatiNow, calendar: kiritimatiCalendar))
		XCTAssertEqual(isoDate("2015-06-04T09:59:59Z"), dateRange.endDate(now: kiritimatiNow, calendar: kiritimatiCalendar))
		
		dateRange = DateRange.calendarUnit(0, .month, hourShift: 0)
		XCTAssertEqual(isoDate("2015-05-31T10:00:00Z"), dateRange.startDate(now: kiritimatiNow, calendar: kiritimatiCalendar))
		XCTAssertEqual(isoDate("2015-06-30T09:59:59Z"), dateRange.endDate(now: kiritimatiNow, calendar: kiritimatiCalendar))
		
		dateRange = DateRange.calendarUnit(-1, .month, hourShift: 0)
		XCTAssertEqual(isoDate("2015-04-30T10:00:00Z"), dateRange.startDate(now: kiritimatiNow, calendar: kiritimatiCalendar))
		XCTAssertEqual(isoDate("2015-05-31T09:59:59Z"), dateRange.endDate(now: kiritimatiNow, calendar: kiritimatiCalendar))
	}
	
	func testDateRangeDescriptionWithNowAndCalendar() {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd"
		dateFormatter.timeZone = kiritimatiCalendar.timeZone
		
		XCTAssertEqual("May 2015", DateRange.calendarUnit(-1, .month, hourShift: 0)
			.dateRangeDescription(withFormatter: dateFormatter, now: kiritimatiNow, calendar: kiritimatiCalendar))
		XCTAssertEqual("2015-06-02 \u{2013} 2015-06-04", DateRange.pastDays(2, hourShift: 0)
			.dateRangeDescription(withFormatter: dateFormatter, relativeDescriptionsAllowed: false,
			                      now: kiritimatiNow, calendar: kiritimatiCalendar))
		XCTAssertEqual("2015-06-04", DateRange.calendarUnit(0, .day, hourShift: 0)
			.dateRangeDescription(withFormatter: dateFormatter, relativeDescriptionsAllowed: false,
			                      now: kiritimatiNow, calendar: kiritimatiCalendar))
	}
	
	func testEqual() {
		let startDate = dateFromString("2015-06-15")
		let endDate = dateFromString("2015-06-17")
		XCTAssertEqual(DateRange.custom(startDate, endDate, hourShift: 0), DateRange.custom(startDate, endDate, hourShift: 0))
		// Custom date ranges are compared on a per-day basis, not per-second.
		XCTAssertEqual(DateRange.custom(startDate.addingTimeInterval(3600), endDate.addingTimeInterval(3600), hourShift: 0),
		               DateRange.custom(startDate, endDate, hourShift: 0))
		XCTAssertNotEqual(DateRange.custom(dateFromString("2015-06-14"), endDate, hourShift: 0),
		                  DateRange.custom(startDate, endDate, hourShift: 0))
		
		XCTAssertEqual(DateRange.pastDays(7, hourShift: 0), DateRange.pastDays(7, hourShift: 0))
		XCTAssertNotEqual(DateRange.pastDays(7, hourShift: 0), DateRange.pastDays(8, hourShift: 0))
		
		XCTAssertEqual(DateRange.calendarUnit(7, .quarter, hourShift: 0), DateRange.calendarUnit(7, .quarter, hourShift: 0))
		XCTAssertNotEqual(DateRange.calendarUnit(7, .quarter, hourShift: 0), DateRange.calendarUnit(7, .quarter, hourShift: 1))
		XCTAssertNotEqual(DateRange.calendarUnit(8, .quarter, hourShift: 0), DateRange.calendarUnit(7, .quarter, hourShift: 0))
		XCTAssertNotEqual(DateRange.calendarUnit(7, .day, hourShift: 0), DateRange.calendarUnit(7, .quarter, hourShift: 0))
		XCTAssertNotEqual(DateRange.calendarUnit(1, .weekOfYear, hourShift: 0), DateRange.calendarUnit(7, .day, hourShift: 0))
	}
	
	func testMoveBy() {
		let startDate = dateFromString("2015-06-15")
		let endDate = dateFromString("2015-06-17")
		
		XCTAssertEqual(DateRange.custom(dateFromString("2015-06-09"), dateFromString("2015-06-11"), hourShift: 0),
		               DateRange.custom(startDate, endDate, hourShift: 0).moveBy(steps: -2))
		
		XCTAssertEqual(DateRange.custom(Date().drp_addCalendarUnits(-92, unit: .day)!,
		                                Date().drp_addCalendarUnits(-62, unit: .day)!,
		                                hourShift: 0),
		               DateRange.pastDays(30, hourShift: 0).moveBy(steps: -2))
		
		//! TEST: Test moveBy with hour shifts.
		/*XCTAssertEqual(DateRange.custom(Date().drp_addCalendarUnits(-92, unit: .day)!,
		                                Date().drp_addCalendarUnits(-62, unit: .day)!,
		                                hourShift: 23),
		               DateRange.pastDays(30, hourShift: 23).moveBy(steps: -2))*/
		
		XCTAssertEqual(DateRange.calendarUnit(-1, .quarter, hourShift: 0),
		               DateRange.calendarUnit(1, .quarter, hourShift: 0).moveBy(steps: -2))
	}
	
	func testMoveByWithTodaysEndDateConvertsToPastDays() {
		XCTAssertEqual(DateRange.pastDays(30, hourShift: 0),
		               DateRange.pastDays(30, hourShift: 0).moveBy(steps: -2).moveBy(steps: 2))
		XCTAssertEqual(DateRange.pastDays(30, hourShift: 23),
		               DateRange.pastDays(30, hourShift: 23).moveBy(steps: -2).moveBy(steps: 2))
	}
	
	func testMoveByWithTodaysEndDateConvertsToToday() {
		XCTAssertEqual(DateRange.calendarUnit(0, .day, hourShift: 0),
		               DateRange.pastDays(0, hourShift: 0).moveBy(steps: -2).moveBy(steps: 2))
		XCTAssertEqual(DateRange.calendarUnit(0, .day, hourShift: 23),
		               DateRange.pastDays(0, hourShift: 23).moveBy(steps: -2).moveBy(steps: 2))
	}
	
	func testMoveByWithNowAndCalendar() {
		let pastDays = DateRange.pastDays(2, hourShift: 0)
		let previous = pastDays.previous(now: kiritimatiNow, calendar: kiritimatiCalendar)
		XCTAssertEqual(isoDate("2015-05-29T10:00:00Z"), previous.startDate(now: kiritimatiNow, calendar: kiritimatiCalendar))
		XCTAssertEqual(isoDate("2015-06-01T09:59:59Z"), previous.endDate(now: kiritimatiNow, calendar: kiritimatiCalendar))
		
		XCTAssertEqual(pastDays, previous.next(now: kiritimatiNow, calendar: kiritimatiCalendar))
		let today = DateRange.pastDays(0, hourShift: 0)
			.moveBy(steps: -2, now: kiritimatiNow, calendar: kiritimatiCalendar)
			.moveBy(steps: 2, now: kiritimatiNow, calendar: kiritimatiCalendar)
		XCTAssertEqual(DateRange.calendarUnit(0, .day, hourShift: 0), today)
	}
	
	func testToFromData() {
		let startDate = dateFromString("2015-06-15")
		let endDate = dateFromString("2015-06-17")
		
		var dateRange = DateRange.custom(startDate, endDate, hourShift: 0)
		XCTAssertEqual(dateRange, DateRange.from(data: dateRange.toData()))
		
		dateRange = DateRange.pastDays(30, hourShift: 0)
		XCTAssertEqual(dateRange, DateRange.from(data: dateRange.toData()))
		
		dateRange = DateRange.calendarUnit(-7, .quarter, hourShift: 0)
		XCTAssertEqual(dateRange, DateRange.from(data: dateRange.toData()))
	}
	
	func testRestrictTo() {
		let startDate = dateFromString("2015-06-15")
		let endDate = dateFromString("2015-06-17")
		
		let dateRange = DateRange.custom(startDate, endDate, hourShift: 0)
		XCTAssertEqual(dateRange, dateRange.restrictTo(minDate: dateFromString("2015-06-01"), maxDate: dateFromString("2015-07-01")))
		
		XCTAssertEqual(DateRange.custom(dateFromString("2015-06-16"), endDate, hourShift: 0),
			dateRange.restrictTo(minDate: dateFromString("2015-06-16"), maxDate: dateFromString("2015-07-01")))
		XCTAssertEqual(DateRange.custom(dateFromString("2015-06-18"), dateFromString("2015-06-18"), hourShift: 0),
			dateRange.restrictTo(minDate: dateFromString("2015-06-18"), maxDate: dateFromString("2015-07-01")))
		
		XCTAssertEqual(DateRange.custom(startDate, dateFromString("2015-06-16"), hourShift: 0),
			dateRange.restrictTo(minDate: dateFromString("2015-06-01"), maxDate: dateFromString("2015-06-16")))
		XCTAssertEqual(DateRange.custom(dateFromString("2015-06-14"), dateFromString("2015-06-14"), hourShift: 0),
			dateRange.restrictTo(minDate: dateFromString("2015-06-01"), maxDate: dateFromString("2015-06-14")))
	}
	
	func testRestrictToWithNowAndCalendar() {
		let pastDays = DateRange.pastDays(2, hourShift: 0)
		XCTAssertEqual(pastDays, pastDays.restrictTo(minDate: isoDate("2015-05-01T00:00:00Z"), maxDate: kiritimatiNow,
		                                             now: kiritimatiNow, calendar: kiritimatiCalendar))
		
		// June 3rd, 08:00 in Kiritimati.
		let june3rd = isoDate("2015-06-02T18:00:00Z")
		let endingJune3rd = pastDays.restrictTo(minDate: nil, maxDate: june3rd, now: kiritimatiNow, calendar: kiritimatiCalendar)
		XCTAssertEqual(isoDate("2015-06-01T10:00:00Z"), endingJune3rd.startDate(now: kiritimatiNow, calendar: kiritimatiCalendar))
		XCTAssertEqual(isoDate("2015-06-03T09:59:59Z"), endingJune3rd.endDate(now: kiritimatiNow, calendar: kiritimatiCalendar))
		
		let startingJune3rd = pastDays.restrictTo(minDate: june3rd, maxDate: nil, now: kiritimatiNow, calendar: kiritimatiCalendar)
		XCTAssertEqual(isoDate("2015-06-02T10:00:00Z"), startingJune3rd.startDate(now: kiritimatiNow, calendar: kiritimatiCalendar))
		XCTAssertEqual(isoDate("2015-06-04T09:59:59Z"), startingJune3rd.endDate(now: kiritimatiNow, calendar: kiritimatiCalendar))
	}
}
