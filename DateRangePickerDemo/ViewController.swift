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
		
		restrictedToFifteenDaysAroundTodayPickerView?.minDate = NSDate().drp_addCalendarUnits(-15, .Day)
		restrictedToFifteenDaysAroundTodayPickerView?.maxDate = NSDate().drp_addCalendarUnits(15, .Day)
		
		restrictedToThisYearPickerView?.minDate = NSDate().drp_beginning(ofCalendarUnit: .Year)
		restrictedToThisYearPickerView?.maxDate = NSDate().drp_end(ofCalendarUnit: .Year)
		restrictedToThisYearPickerView?.dateRange = .CalendarUnit(0, .Month)
	}
	
	override func viewDidAppear() {
		self.view.window?.titleVisibility = .Hidden
	}
}

