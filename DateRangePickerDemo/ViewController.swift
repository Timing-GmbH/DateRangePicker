//
//  ViewController.swift
//  DateRangePickerDemo
//
//  Created by Daniel Alm on 07.11.15.
//  Copyright © 2015 Daniel Alm. All rights reserved.
//

import Cocoa

import DateRangePicker

class ViewController: NSViewController {
	@IBOutlet var restrictedToFifteenDaysAroundTodayPickerView: DateRangePickerView?
	@IBOutlet var restrictedToThisYearPickerView: DateRangePickerView?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		preferredContentSize = view.bounds.size
		
		restrictedToFifteenDaysAroundTodayPickerView?.minDate = Date().drp_addCalendarUnits(-15, unit: .day)
		restrictedToFifteenDaysAroundTodayPickerView?.maxDate = Date().drp_addCalendarUnits(15, unit: .day)
		
		restrictedToThisYearPickerView?.minDate = Date().drp_beginning(ofCalendarUnit: .year)
		restrictedToThisYearPickerView?.maxDate = Date().drp_end(ofCalendarUnit: .year)
		restrictedToThisYearPickerView?.dateRange = .calendarUnit(0, .month, hourShift: 0)
	}
	
	override func viewDidAppear() {
		self.view.window?.titleVisibility = .hidden
	}
}

