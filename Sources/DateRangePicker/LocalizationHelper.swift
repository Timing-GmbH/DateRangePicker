//
//  LocalizationHelper.swift
//  DateRangePicker
//
//  Created by Daniel Alm on 09.11.15.
//  Copyright © 2015 Daniel Alm. All rights reserved.
//

import Foundation

func getBundle() -> Bundle {
	#if SWIFT_PACKAGE
	return Bundle.module
	#else
	return Bundle(for: DateRangePickerView.self)
	#endif
}
