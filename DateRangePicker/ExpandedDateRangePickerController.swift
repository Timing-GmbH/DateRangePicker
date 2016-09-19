//
//  ExpandedDateRangePickerController.swift
//  DateRangePicker
//
//  Created by Daniel Alm on 07.11.15.
//  Copyright © 2015 Daniel Alm. All rights reserved.
//

import Cocoa

//! CLEANUP: Migrate to Swift 3 naming convention.
public protocol ExpandedDateRangePickerControllerDelegate: class {
	func expandedDateRangePickerControllerDidChangeDateRange(_ controller: ExpandedDateRangePickerController)
}

open class ExpandedDateRangePickerController: NSViewController {
	let presetRanges: [DateRange?] = [
		.custom(Date(), Date()),
		nil,
		.pastDays(7),
		.pastDays(15),
		.pastDays(30),
		.pastDays(90),
		.pastDays(365),
		nil,
		.calendarUnit(0, .day),
		.calendarUnit(-1, .day),
		.calendarUnit(0, .weekOfYear),
		.calendarUnit(0, .month),
		.calendarUnit(0, .quarter),
		.calendarUnit(0, .year)
	]
	@IBOutlet var presetRangeSelector: NSPopUpButton?
	
	fileprivate var _dateRange: DateRange
	open var dateRange: DateRange {
		get {
			return _dateRange
		}
		
		set {
			self.willChangeValue(forKey: "endDate")
			self.willChangeValue(forKey: "startDate")
			_dateRange = newValue.restrictTo(minDate: minDate, maxDate: maxDate)
			self.didChangeValue(forKey: "endDate")
			self.didChangeValue(forKey: "startDate")
			
			presetRangeSelector?.selectItem(at: presetRanges.index(where: { $0 == dateRange }) ?? 0)
			delegate?.expandedDateRangePickerControllerDidChangeDateRange(self)
		}
	}
	
	// These are needed for the bindings with NSDatePicker
	open dynamic var startDate: Date {
		get {
			return dateRange.startDate
		}
		
		set {
			dateRange = DateRange.custom(newValue, endDate)
		}
	}
	open dynamic var endDate: Date {
		get {
			return dateRange.endDate
		}
		
		set {
			dateRange = DateRange.custom(startDate, newValue)
		}
	}
	
	// Can be used for restricting the selectable dates to a specific range.
	open dynamic var minDate: Date? {
		didSet {
			// Enforces the new date range restriction
			dateRange = _dateRange
		}
	}
	open dynamic var maxDate: Date? {
		didSet {
			// Enforces the new date range restriction
			dateRange = _dateRange
		}
	}
	
	open weak var delegate: ExpandedDateRangePickerControllerDelegate?
	
	public init(dateRange: DateRange) {
		_dateRange = dateRange
		super.init(nibName: "ExpandedDateRangePickerController",
			bundle: Bundle(for: ExpandedDateRangePickerController.self))!
	}
	
	public required init?(coder: NSCoder) {
        return nil
	}
	
	open override func awakeFromNib() {
		super.awakeFromNib()
		
		guard let menu = presetRangeSelector?.menu else { return }
		for range in presetRanges {
			let menuItem: NSMenuItem
			if let range = range {
				guard let title = range.title else { continue }
				menuItem = NSMenuItem(title: title, action: nil, keyEquivalent: "")
			} else {
				menuItem = NSMenuItem.separator()
			}
			menu.addItem(menuItem)
		}
		presetRangeSelector?.selectItem(at: presetRanges.index(where: { $0 == dateRange }) ?? 0)
	}
	
	@IBAction func presetRangeSelected(_ sender: NSPopUpButton) {
		guard let selectedRange = presetRanges[sender.indexOfSelectedItem] else { return }
		switch selectedRange {
		case .custom:
			dateRange = DateRange.custom(startDate, endDate)
		case .pastDays, .calendarUnit:
			dateRange = selectedRange
		}
	}
}
