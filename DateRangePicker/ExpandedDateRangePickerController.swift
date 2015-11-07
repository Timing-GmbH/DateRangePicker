//
//  ExpandedDateRangePickerController.swift
//  DateRangePicker
//
//  Created by Daniel Alm on 07.11.15.
//  Copyright © 2015 Daniel Alm. All rights reserved.
//

import Cocoa

class ExpandedDateRangePickerController: NSViewController {
	dynamic var startDate: NSDate
	dynamic var endDate: NSDate
	
	init(startDate: NSDate, endDate: NSDate) {
		self.startDate = startDate
		self.endDate = endDate
		super.init(nibName: ExpandedDateRangePickerController.className(),
			bundle: NSBundle(forClass: ExpandedDateRangePickerController.self))!
	}
	
	required init?(coder: NSCoder) {
		startDate = NSDate()
		endDate = NSDate()
		super.init(coder: coder)
		assert(false, "This initializer should not be used.")
	}

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
}
