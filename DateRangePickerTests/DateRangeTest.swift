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
	func dateFromString(_ dateString: String) -> Date {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd"
		return dateFormatter.date(from: dateString)!
	}
	
	func testTitle() {
		XCTAssertEqual("Custom", DateRange.custom(Date(), Date()).title)
		
		XCTAssertEqual("Past 7 Days", DateRange.pastDays(7).title)
		
		XCTAssertEqual("This Quarter", DateRange.calendarUnit(0, .quarter).title)
	}
	
	func testStartEndDates() {
		let startDate = dateFromString("2015-06-15")
		let endDate = dateFromString("2015-06-17")
		
		var dateRange = DateRange.custom(startDate, endDate)
		XCTAssertEqual(startDate, dateRange.startDate)
		XCTAssertEqual(endDate.drp_end(ofCalendarUnit: .day), dateRange.endDate)
		
		// Being able to specify a reference date would be nicer for testability,
		// but then the API would likely get very unwieldy.
		dateRange = DateRange.pastDays(30)
		XCTAssertEqual(Date().drp_addCalendarUnits(-30, unit: .day)!.drp_beginning(ofCalendarUnit: .day), dateRange.startDate)
		XCTAssertEqual(Date().drp_end(ofCalendarUnit: .day), dateRange.endDate)
		
		dateRange = DateRange.calendarUnit(0, .quarter)
		XCTAssertEqual(Date().drp_beginning(ofCalendarUnit: .quarter), dateRange.startDate)
		XCTAssertEqual(Date().drp_end(ofCalendarUnit: .quarter), dateRange.endDate)
		
		dateRange = DateRange.calendarUnit(-1, .quarter)
		XCTAssertEqual(Date().drp_addCalendarUnits(-1, unit: .quarter)!.drp_beginning(ofCalendarUnit: .quarter), dateRange.startDate)
		XCTAssertEqual(Date().drp_addCalendarUnits(-1, unit: .quarter)!.drp_end(ofCalendarUnit: .quarter), dateRange.endDate)
		
		dateRange = DateRange.calendarUnit(1, .quarter)
		XCTAssertEqual(Date().drp_addCalendarUnits(1, unit: .quarter)!.drp_beginning(ofCalendarUnit: .quarter), dateRange.startDate)
		XCTAssertEqual(Date().drp_addCalendarUnits(1, unit: .quarter)!.drp_end(ofCalendarUnit: .quarter), dateRange.endDate)
	}
	
	func testEqual() {
		let startDate = dateFromString("2015-06-15")
		let endDate = dateFromString("2015-06-17")
		XCTAssertEqual(DateRange.custom(startDate, endDate), DateRange.custom(startDate, endDate))
		// Custom date ranges are compared on a per-day basis, not per-second.
		XCTAssertEqual(DateRange.custom(startDate.addingTimeInterval(3600), endDate.addingTimeInterval(3600)), DateRange.custom(startDate, endDate))
		XCTAssertNotEqual(DateRange.custom(dateFromString("2015-06-14"), endDate), DateRange.custom(startDate, endDate))
		
		XCTAssertEqual(DateRange.pastDays(7), DateRange.pastDays(7))
		XCTAssertNotEqual(DateRange.pastDays(7), DateRange.pastDays(8))
		
		XCTAssertEqual(DateRange.calendarUnit(7, .quarter), DateRange.calendarUnit(7, .quarter))
		XCTAssertNotEqual(DateRange.calendarUnit(8, .quarter), DateRange.calendarUnit(7, .quarter))
		XCTAssertNotEqual(DateRange.calendarUnit(7, .day), DateRange.calendarUnit(7, .quarter))
		XCTAssertNotEqual(DateRange.calendarUnit(1, .weekOfYear), DateRange.calendarUnit(7, .day))
	}
	
	func testMoveBy() {
		let startDate = dateFromString("2015-06-15")
		let endDate = dateFromString("2015-06-17")
		
		XCTAssertEqual(DateRange.custom(dateFromString("2015-06-09"), dateFromString("2015-06-11")), DateRange.custom(startDate, endDate).moveBy(steps: -2))
		
		XCTAssertEqual(DateRange.custom(Date().drp_addCalendarUnits(-92, unit: .day)!, Date().drp_addCalendarUnits(-62, unit: .day)!),
		               DateRange.pastDays(30).moveBy(steps: -2))
		
		XCTAssertEqual(DateRange.calendarUnit(-1, .quarter), DateRange.calendarUnit(1, .quarter).moveBy(steps: -2))
	}
	
	func testMoveByWithTodaysEndDateConvertsToPastDays() {
		XCTAssertEqual(DateRange.pastDays(30), DateRange.pastDays(30).moveBy(steps: -2).moveBy(steps: 2))
	}
	
	func testMoveByWithTodaysEndDateConvertsToToday() {
		XCTAssertEqual(DateRange.calendarUnit(0, .day), DateRange.pastDays(0).moveBy(steps: -2).moveBy(steps: 2))
	}
	
	func testToFromData() {
		let startDate = dateFromString("2015-06-15")
		let endDate = dateFromString("2015-06-17")
		
		var dateRange = DateRange.custom(startDate, endDate)
		XCTAssertEqual(dateRange, DateRange.from(data: dateRange.toData()))
		
		dateRange = DateRange.pastDays(30)
		XCTAssertEqual(dateRange, DateRange.from(data: dateRange.toData()))
		
		dateRange = DateRange.calendarUnit(-7, .quarter)
		XCTAssertEqual(dateRange, DateRange.from(data: dateRange.toData()))
	}
	
	func testRestrictTo() {
		let startDate = dateFromString("2015-06-15")
		let endDate = dateFromString("2015-06-17")
		
		let dateRange = DateRange.custom(startDate, endDate)
		XCTAssertEqual(dateRange, dateRange.restrictTo(minDate: dateFromString("2015-06-01"), maxDate: dateFromString("2015-07-01")))
		
		XCTAssertEqual(DateRange.custom(dateFromString("2015-06-16"), endDate),
			dateRange.restrictTo(minDate: dateFromString("2015-06-16"), maxDate: dateFromString("2015-07-01")))
		XCTAssertEqual(DateRange.custom(dateFromString("2015-06-18"), dateFromString("2015-06-18")),
			dateRange.restrictTo(minDate: dateFromString("2015-06-18"), maxDate: dateFromString("2015-07-01")))
		
		XCTAssertEqual(DateRange.custom(startDate, dateFromString("2015-06-16")),
			dateRange.restrictTo(minDate: dateFromString("2015-06-01"), maxDate: dateFromString("2015-06-16")))
		XCTAssertEqual(DateRange.custom(dateFromString("2015-06-14"), dateFromString("2015-06-14")),
			dateRange.restrictTo(minDate: dateFromString("2015-06-01"), maxDate: dateFromString("2015-06-14")))
	}
}
