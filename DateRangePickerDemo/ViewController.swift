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
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		preferredContentSize = view.bounds.size
		
		restrictedToFifteenDaysAroundTodayPickerView?.minDate = NSDate().drp_addCalendarUnits(-15, .Day)
		restrictedToFifteenDaysAroundTodayPickerView?.maxDate = NSDate().drp_addCalendarUnits(15, .Day)
	}
	
	override func viewDidAppear() {
		self.view.window?.titleVisibility = .Hidden
	}
}

