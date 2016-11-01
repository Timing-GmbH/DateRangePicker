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
		
		restrictedToFifteenDaysAroundTodayPickerView?.minDate = NSDate().drp_addCalendarUnits(count: -15, .day)
		restrictedToFifteenDaysAroundTodayPickerView?.maxDate = NSDate().drp_addCalendarUnits(count: 15, .day)
		
		restrictedToThisYearPickerView?.minDate = NSDate().drp_beginningOfCalendarUnit(unit: .year)
		restrictedToThisYearPickerView?.maxDate = NSDate().drp_endOfCalendarUnit(unit: .year)
		restrictedToThisYearPickerView?.dateRange = .calendarUnit(0, .month)
	}
	
	override func viewDidAppear() {
		self.view.window?.titleVisibility = .hidden
	}
}

