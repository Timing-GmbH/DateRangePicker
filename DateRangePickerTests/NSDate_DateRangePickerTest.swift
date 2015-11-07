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
	
	func testAddDays() {
		XCTAssertEqual(dateFromString("2015-06-10"), dateFromString("2015-06-03").drp_addDays(7))
		XCTAssertEqual(dateFromString("2015-06-10"), dateFromString("2015-06-17").drp_addDays(-7))
		XCTAssertEqual(dateFromString("2015-10-25"), dateFromString("2015-10-18").drp_addDays(7))
		XCTAssertEqual(dateFromString("2015-07-03"), dateFromString("2015-06-26").drp_addDays(7))
    }
	
	func testDaysSince() {
		XCTAssertEqual(7, dateFromString("2015-06-10").drp_daysSince(dateFromString("2015-06-03")))
		
		// Use a calendar with DST to verify wrapping during DST changes
		let calendar = NSCalendar.currentCalendar()
		calendar.timeZone = NSTimeZone(name: "Europe/Berlin")!
		XCTAssertEqual(7, dateFromString("2015-10-27").drp_daysSince(dateFromString("2015-10-20")))
		XCTAssertEqual(-7, dateFromString("2015-10-20").drp_daysSince(dateFromString("2015-10-27")))
		XCTAssertEqual(7, dateFromString("2015-04-01").drp_daysSince(dateFromString("2015-03-25")))
		XCTAssertEqual(-7, dateFromString("2015-03-25").drp_daysSince(dateFromString("2015-04-01")))
	}
}
