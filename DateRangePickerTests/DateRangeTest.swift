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
		XCTAssertEqual(endDate.drp_endOfCalendarUnit(unit: .day), dateRange.endDate)
		
		// Being able to specify a reference date would be nicer for testability,
		// but then the API would likely get very unwieldy.
		dateRange = DateRange.pastDays(30)
		XCTAssertEqual(Date().drp_addCalendarUnits(count: -30, .day)!.drp_beginningOfCalendarUnit(unit: .day), dateRange.startDate)
		XCTAssertEqual(Date().drp_endOfCalendarUnit(unit: .day), dateRange.endDate)
		
		dateRange = DateRange.calendarUnit(0, .quarter)
		XCTAssertEqual(Date().drp_beginningOfCalendarUnit(unit: .quarter), dateRange.startDate)
		XCTAssertEqual(Date().drp_endOfCalendarUnit(unit: .quarter), dateRange.endDate)
		
		dateRange = DateRange.calendarUnit(-1, .quarter)
		XCTAssertEqual(Date().drp_addCalendarUnits(count: -1, .quarter)!.drp_beginningOfCalendarUnit(unit: .quarter), dateRange.startDate)
		XCTAssertEqual(Date().drp_addCalendarUnits(count: -1, .quarter)!.drp_endOfCalendarUnit(unit: .quarter), dateRange.endDate)
		
		dateRange = DateRange.calendarUnit(1, .quarter)
		XCTAssertEqual(Date().drp_addCalendarUnits(count: 1, .quarter)!.drp_beginningOfCalendarUnit(unit: .quarter), dateRange.startDate)
		XCTAssertEqual(Date().drp_addCalendarUnits(count: 1, .quarter)!.drp_endOfCalendarUnit(unit: .quarter), dateRange.endDate)
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
		
		XCTAssertEqual(DateRange.custom(dateFromString("2015-06-09"), dateFromString("2015-06-11")), DateRange.custom(startDate, endDate).moveBy(-2))
		
		XCTAssertEqual(DateRange.custom(Date().drp_addCalendarUnits(count: -92, .day)!, Date().drp_addCalendarUnits(count: -62, .day)!),
			DateRange.pastDays(30).moveBy(-2))
		
		XCTAssertEqual(DateRange.calendarUnit(-1, .quarter), DateRange.calendarUnit(1, .quarter).moveBy(-2))
	}
	
	func testToFromData() {
		let startDate = dateFromString("2015-06-15")
		let endDate = dateFromString("2015-06-17")
		
		var dateRange = DateRange.custom(startDate, endDate)
		XCTAssertEqual(dateRange, DateRange.fromData(dateRange.toData()))
		
		dateRange = DateRange.pastDays(30)
		XCTAssertEqual(dateRange, DateRange.fromData(dateRange.toData()))
		
		dateRange = DateRange.calendarUnit(-7, .quarter)
		XCTAssertEqual(dateRange, DateRange.fromData(dateRange.toData()))
	}
	
	func testRestrictToDates() {
		let startDate = dateFromString("2015-06-15")
		let endDate = dateFromString("2015-06-17")
		
		let dateRange = DateRange.custom(startDate, endDate)
		XCTAssertEqual(dateRange, dateRange.restrictToDates(dateFromString("2015-06-01") as NSDate?, dateFromString("2015-07-01") as NSDate?))
		
		XCTAssertEqual(DateRange.custom(dateFromString("2015-06-16"), endDate),
			dateRange.restrictToDates(dateFromString("2015-06-16") as NSDate?, dateFromString("2015-07-01") as NSDate?))
		XCTAssertEqual(DateRange.custom(dateFromString("2015-06-18"), dateFromString("2015-06-18")),
			dateRange.restrictToDates(dateFromString("2015-06-18") as NSDate?, dateFromString("2015-07-01") as NSDate?))
		
		XCTAssertEqual(DateRange.custom(startDate, dateFromString("2015-06-16")),
			dateRange.restrictToDates(dateFromString("2015-06-01") as NSDate?, dateFromString("2015-06-16") as NSDate?))
		XCTAssertEqual(DateRange.custom(dateFromString("2015-06-14"), dateFromString("2015-06-14")),
			dateRange.restrictToDates(dateFromString("2015-06-01") as NSDate?, dateFromString("2015-06-14") as NSDate?))
	}
}
