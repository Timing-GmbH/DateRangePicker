//
//  DateRangePickerViewMouseTest.swift
//  DateRangePicker
//
//  Copyright © 2015 Daniel Alm. All rights reserved.
//

import XCTest
@testable import DateRangePicker

final class DateRangePickerViewMouseTest: XCTestCase {
	private final class ActionCounter: NSObject {
		var count = 0
		@objc func act(_ sender: Any?) { count += 1 }
	}

	// A disabled segment of the segmented control passes its mouse-down on to the picker view, which must not track it:
	// tracking highlights the whole view as long as the mouse button is held, and sends the picker's action on release.
	func testMouseDownForwardedFromDisabledSegmentIsIgnored() throws {
		let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 300, height: 50), styleMask: [.titled], backing: .buffered, defer: false)
		let picker = DateRangePickerView(frame: NSRect(x: 10, y: 10, width: 200, height: 24))
		window.contentView?.addSubview(picker)
		let counter = ActionCounter()
		picker.target = counter
		picker.action = #selector(ActionCounter.act(_:))
		picker.segmentedControl.setEnabled(false, forSegment: 2)

		let location = picker.convert(NSPoint(x: picker.bounds.maxX - 6, y: picker.bounds.midY), to: nil)
		let mouseDown = try XCTUnwrap(NSEvent.mouseEvent(with: .leftMouseDown, location: location, modifierFlags: [], timestamp: 0, windowNumber: window.windowNumber, context: nil, eventNumber: 0, clickCount: 1, pressure: 1))
		let mouseUp = try XCTUnwrap(NSEvent.mouseEvent(with: .leftMouseUp, location: location, modifierFlags: [], timestamp: 0, windowNumber: window.windowNumber, context: nil, eventNumber: 1, clickCount: 1, pressure: 0))
		NSApplication.shared.postEvent(mouseUp, atStart: false)
		defer { NSApplication.shared.discardEvents(matching: .leftMouseUp, before: nil) }

		picker.mouseDown(with: mouseDown)

		XCTAssertEqual(counter.count, 0)
	}
}
