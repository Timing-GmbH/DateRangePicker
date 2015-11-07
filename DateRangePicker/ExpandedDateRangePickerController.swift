//
//  ExpandedDateRangePickerController.swift
//  DateRangePicker
//
//  Created by Daniel Alm on 07.11.15.
//  Copyright © 2015 Daniel Alm. All rights reserved.
//

import Cocoa

extension DateRange {
	func buildMenuItem() -> NSMenuItem {
		switch (self) {
		case Custom:
			fallthrough
		case PastDays(_):
			fallthrough
		case CurrentCalendarUnit(_):
			return NSMenuItem(title: title, action: nil, keyEquivalent: "")
		case None:
			return NSMenuItem.separatorItem()
		}
	}
}

class ExpandedDateRangePickerController: NSViewController {
	dynamic var startDate: NSDate
	dynamic var endDate: NSDate
	
	@IBOutlet var presetRangeSelector: NSPopUpButton?
	let presetRanges: [DateRange] = [
		.Custom,
		.None,
		.PastDays(7),
		.PastDays(15),
		.PastDays(30),
		.PastDays(90),
		.PastDays(365),
		.None,
		.CurrentCalendarUnit(.WeekOfYear),
		.CurrentCalendarUnit(.Month),
		.CurrentCalendarUnit(.Quarter),
		.CurrentCalendarUnit(.Year)
	]
	
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
		
		guard let menu = presetRangeSelector?.menu else { return }
		for range in presetRanges {
			menu.addItem(range.buildMenuItem())
		}
    }
	
	@IBAction func presetRangeSelected(sender: NSPopUpButton) {
		print(presetRanges[sender.indexOfSelectedItem])
	}
}
