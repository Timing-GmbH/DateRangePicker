//
//  DateRangeTest.swift
//  DateRangePicker
//
//  Created by Christian Tietze on 08.06.23.
//  Copyright © 2015 Daniel Alm. All rights reserved.
//

import XCTest
@testable import DateRangePicker

final class AssetTests: XCTestCase {
	func testSeparatorColor() {
		XCTAssertNotNil(ExpandedDateRangePickerController.separatorColor)
	}
}
