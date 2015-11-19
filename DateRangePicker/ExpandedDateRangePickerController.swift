//
//  ExpandedDateRangePickerController.swift
//  DateRangePicker
//
//  Created by Daniel Alm on 07.11.15.
//  Copyright © 2015 Daniel Alm. All rights reserved.
//

import Cocoa

public protocol ExpandedDateRangePickerControllerDelegate: class {
	func expandedDateRangePickerControllerDidChangeDateRange(controller: ExpandedDateRangePickerController)
}

public class ExpandedDateRangePickerController: NSViewController {
	let presetRanges: [DateRange] = [
		.Custom(NSDate(), NSDate()),
		.None,
		.PastDays(7),
		.PastDays(15),
		.PastDays(30),
		.PastDays(90),
		.PastDays(365),
		.None,
		.CalendarUnit(0, .Day),
		.CalendarUnit(-1, .Day),
		.CalendarUnit(0, .WeekOfYear),
		.CalendarUnit(0, .Month),
		.CalendarUnit(0, .Quarter),
		.CalendarUnit(0, .Year)
	]
	@IBOutlet var presetRangeSelector: NSPopUpButton?
	
	private var _dateRange: DateRange
	public var dateRange: DateRange {
		get {
			return _dateRange
		}
		
		set {
			self.willChangeValueForKey("endDate")
			self.willChangeValueForKey("startDate")
			_dateRange = newValue.restrictToDates(minDate, maxDate)
			self.didChangeValueForKey("endDate")
			self.didChangeValueForKey("startDate")
			
			presetRangeSelector?.selectItemAtIndex(presetRanges.indexOf({ $0 == dateRange }) ?? 0)
			delegate?.expandedDateRangePickerControllerDidChangeDateRange(self)
		}
	}
	
	// These are needed for the bindings with NSDatePicker
	public dynamic var startDate: NSDate {
		get {
			return dateRange.startDate!
		}
		
		set {
			dateRange = DateRange.Custom(newValue, endDate)
		}
	}
	public dynamic var endDate: NSDate {
		get {
			return dateRange.endDate!
		}
		
		set {
			dateRange = DateRange.Custom(startDate, newValue)
		}
	}
	
	// Can be used for restricting the selectable dates to a specific range.
	public dynamic var minDate: NSDate? {
		didSet {
			// Enforces the new date range restriction
			dateRange = _dateRange
		}
	}
	public dynamic var maxDate: NSDate? {
		didSet {
			// Enforces the new date range restriction
			dateRange = _dateRange
		}
	}
	
	public weak var delegate: ExpandedDateRangePickerControllerDelegate?
	
	public init(dateRange: DateRange) {
		_dateRange = dateRange
		super.init(nibName: "ExpandedDateRangePickerController",
			bundle: NSBundle(forClass: ExpandedDateRangePickerController.self))!
	}
	
	public required init?(coder: NSCoder) {
		_dateRange = .None
		super.init(coder: coder)
		assert(false, "This initializer should not be used.")
	}
	
	public override func awakeFromNib() {
		super.awakeFromNib()
		
		guard let menu = presetRangeSelector?.menu else { return }
		for range in presetRanges {
			let menuItem: NSMenuItem
			switch range {
			case .None:
				menuItem = NSMenuItem.separatorItem()
			default:
				guard let title = range.title else { continue }
				menuItem = NSMenuItem(title: title, action: nil, keyEquivalent: "")
			}
			
			menu.addItem(menuItem)
		}
		presetRangeSelector?.selectItemAtIndex(presetRanges.indexOf({ $0 == dateRange }) ?? 0)
	}
	
	@IBAction func presetRangeSelected(sender: NSPopUpButton) {
		let selectedRange = presetRanges[sender.indexOfSelectedItem]
		switch selectedRange {
		case .Custom, .None:
			dateRange = DateRange.Custom(startDate, endDate)
		case .PastDays, .CalendarUnit:
			dateRange = selectedRange
		}
	}
}
