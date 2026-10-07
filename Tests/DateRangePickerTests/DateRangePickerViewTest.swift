//
//  DateRangePickerViewTest.swift
//  DateRangePicker
//
//  Created by Christian Tietze on 07.10.26.
//  Copyright © 2015 Daniel Alm. All rights reserved.
//

import XCTest
@testable import DateRangePicker

final class DateRangePickerViewTest: XCTestCase {
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
	
	func makePicker() -> DateRangePickerView {
		let picker = DateRangePickerView(frame: .zero)
		picker.calendar = kiritimatiCalendar
		let now = kiritimatiNow
		picker.now = { now }
		return picker
	}
	
	func testDatesUseNowAndCalendar() {
		let picker = makePicker()
		picker.dateRange = .pastDays(2, hourShift: 0)
		XCTAssertEqual(isoDate("2015-06-01T10:00:00Z"), picker.startDate)
		XCTAssertEqual(isoDate("2015-06-04T09:59:59Z"), picker.endDate)
	}
	
	func testMaxDateRestrictsRelativeToNowAndCalendar() {
		let picker = makePicker()
		picker.dateRange = .pastDays(2, hourShift: 0)
		// June 3rd, 08:00 in Kiritimati.
		picker.maxDate = isoDate("2015-06-02T18:00:00Z")
		XCTAssertEqual(isoDate("2015-06-01T10:00:00Z"), picker.startDate)
		XCTAssertEqual(isoDate("2015-06-03T09:59:59Z"), picker.endDate)
	}
	
	func testSelectPreviousDateRangeUsesNowAndCalendar() {
		let picker = makePicker()
		picker.dateRange = .pastDays(2, hourShift: 0)
		picker.selectPreviousDateRange(nil)
		XCTAssertEqual(isoDate("2015-05-29T10:00:00Z"), picker.startDate)
		XCTAssertEqual(isoDate("2015-06-01T09:59:59Z"), picker.endDate)
	}
	
	func testLabelUsesNowAndCalendar() {
		let picker = makePicker()
		picker.dateRange = .calendarUnit(-1, .month, hourShift: 0)
		XCTAssertEqual("May 2015", picker.segmentedControl.label(forSegment: 1))
		
		picker.dateFormatter.dateFormat = "yyyy-MM-dd"
		picker.dateRange = .custom(kiritimatiNow, kiritimatiNow, hourShift: 0)
		XCTAssertEqual("2015-06-04", picker.segmentedControl.label(forSegment: 1))
	}
	
	func testNextIsDisabledAtMaxDate() {
		let picker = makePicker()
		picker.maxDate = kiritimatiNow
		picker.dateRange = .pastDays(2, hourShift: 0)
		XCTAssertFalse(picker.segmentedControl.isEnabled(forSegment: 2))
		
		picker.selectPreviousDateRange(nil)
		XCTAssertTrue(picker.segmentedControl.isEnabled(forSegment: 2))
	}
	
	func testExpandedControllerUsesNowAndCalendar() {
		let controller = ExpandedDateRangePickerController(dateRange: .pastDays(2, hourShift: 0), hourShift: 0)
		controller.calendar = kiritimatiCalendar
		let now = kiritimatiNow
		controller.now = { now }
		XCTAssertEqual(isoDate("2015-06-01T10:00:00Z"), controller.startDate)
		XCTAssertEqual(isoDate("2015-06-04T09:59:59Z"), controller.endDate)
		
		_ = controller.view
		XCTAssertEqual(kiritimatiCalendar, controller.startDateCalendarPicker?.calendar)
		XCTAssertEqual(kiritimatiCalendar.timeZone, controller.startDateCalendarPicker?.timeZone)
		XCTAssertEqual(kiritimatiCalendar, controller.endDateCalendarPicker?.calendar)
		XCTAssertEqual(kiritimatiCalendar.timeZone, controller.endDateCalendarPicker?.timeZone)
	}
	
	func testExpandedControllerAppliesCalendarToLoadedDatePickers() {
		let controller = ExpandedDateRangePickerController(dateRange: .pastDays(2, hourShift: 0), hourShift: 0)
		_ = controller.view
		controller.calendar = kiritimatiCalendar
		XCTAssertEqual(kiritimatiCalendar.timeZone, controller.startDateCalendarPicker?.timeZone)
		XCTAssertEqual(kiritimatiCalendar.timeZone, controller.endDateCalendarPicker?.timeZone)
	}
	
	func testExpandedControllerLeavesDatePickersOnSystemTimeZoneByDefault() {
		let controller = ExpandedDateRangePickerController(dateRange: .pastDays(2, hourShift: 0), hourShift: 0)
		_ = controller.view
		XCTAssertNil(controller.startDateCalendarPicker?.timeZone)
		XCTAssertNil(controller.endDateCalendarPicker?.timeZone)
	}
	
	func presentedController(of picker: DateRangePickerView) -> ExpandedDateRangePickerController? {
		let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 300, height: 100),
		                      styleMask: [.titled], backing: .buffered, defer: false)
		window.contentView?.addSubview(picker)
		let delegate = PresentationRecorder()
		picker.delegate = delegate
		picker.displayExpandedDatePicker()
		return delegate.presentedController
	}
	
	func testPickerPassesNowAndCalendarToExpandedController() {
		let controller = presentedController(of: makePicker())
		XCTAssertEqual(kiritimatiCalendar, controller?.calendar)
		XCTAssertEqual(kiritimatiNow, controller?.now())
	}
	
	func testPickerLeavesExpandedControllerOnSystemTimeZoneByDefault() {
		let controller = presentedController(of: DateRangePickerView(frame: .zero))
		XCTAssertNotNil(controller)
		XCTAssertNil(controller?.startDateCalendarPicker?.timeZone)
	}
}

private final class PresentationRecorder: NSObject, DateRangePickerViewDelegate {
	var presentedController: ExpandedDateRangePickerController?
	
	func dateRangePickerView(_ dateRangePickerView: DateRangePickerView,
	                         willPresentExpandedDateRangePickerController expandedDateRangePickerController: ExpandedDateRangePickerController) {
		presentedController = expandedDateRangePickerController
	}
	
	func dateRangePickerViewDidCloseExpandedDateRangePickerController(_ dateRangePickerView: DateRangePickerView) {}
}
