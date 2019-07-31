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
	@IBOutlet var auxiliaryViewContainer: NSView?
	@IBOutlet var constraintHidingAuxiliaryView: NSLayoutConstraint?
	
	open var auxiliaryView: NSView? {
		didSet {
			_ = self.view  // Ensures that the view is loaded and outlets are set up.
			
			guard let auxiliaryViewContainer = auxiliaryViewContainer,
				let constraintHidingAuxiliaryView = constraintHidingAuxiliaryView
				else { return }
			
			for subview in auxiliaryViewContainer.subviews {
				subview.removeFromSuperview()
			}
			
			self.view.removeConstraint(constraintHidingAuxiliaryView)
			
			if let auxiliaryView = auxiliaryView {
				auxiliaryView.translatesAutoresizingMaskIntoConstraints = false
				auxiliaryViewContainer.addSubview(auxiliaryView)
				auxiliaryViewContainer.addConstraints(NSLayoutConstraint.constraints(
					withVisualFormat: "H:|[auxiliaryView]|", options: [], metrics: nil,
					views: ["auxiliaryView": auxiliaryView]))
				auxiliaryViewContainer.addConstraints(NSLayoutConstraint.constraints(
					withVisualFormat: "V:|[auxiliaryView]|", options: [], metrics: nil,
					views: ["auxiliaryView": auxiliaryView]))
			} else {
				self.view.addConstraint(constraintHidingAuxiliaryView)
			}
		}
	}
	
	var presetRanges: [DateRange?] {
		return [
			.custom(Date(), Date(), hourShift: self.hourShift),
			nil,
			.pastDays(7, hourShift: self.hourShift),
			.pastDays(15, hourShift: self.hourShift),
			.pastDays(30, hourShift: self.hourShift),
			.pastDays(90, hourShift: self.hourShift),
			.pastDays(365, hourShift: self.hourShift),
			nil,
			.calendarUnit(0, .day, hourShift: self.hourShift),
			.calendarUnit(0, .weekOfYear, hourShift: self.hourShift),
			.calendarUnit(0, .month, hourShift: self.hourShift),
			.calendarUnit(0, .quarter, hourShift: self.hourShift),
			.calendarUnit(0, .year, hourShift: self.hourShift),
			nil,
			.calendarUnit(-1, .day, hourShift: self.hourShift),
			.calendarUnit(-1, .weekOfYear, hourShift: self.hourShift),
			.calendarUnit(-1, .month, hourShift: self.hourShift)
		]
	}
	@IBOutlet var presetRangeSelector: NSPopUpButton?
	
	@objc open dynamic var hourShift: Int = 0 {
		didSet { dateRange.hourShift = hourShift }
	}
	
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
			
			presetRangeSelector?.selectItem(at: presetRanges.firstIndex(where: { $0 == dateRange }) ?? 0)
			delegate?.expandedDateRangePickerControllerDidChangeDateRange(self)
		}
	}
	
	// These are needed for the bindings with NSDatePicker
	@objc open dynamic var startDate: Date {
		get {
			return dateRange.startDate
		}
		
		set {
			dateRange = DateRange.custom(newValue, max(newValue, endDate), hourShift: self.hourShift)
		}
	}
	@objc open dynamic var endDate: Date {
		get {
			return dateRange.endDate
		}
		
		set {
			dateRange = DateRange.custom(min(newValue, startDate), newValue, hourShift: self.hourShift)
		}
	}
	
	// Can be used for restricting the selectable dates to a specific range.
	@objc open dynamic var minDate: Date? {
		didSet {
			// Enforces the new date range restriction
			dateRange = _dateRange
		}
	}
	@objc open dynamic var maxDate: Date? {
		didSet {
			// Enforces the new date range restriction
			dateRange = _dateRange
		}
	}
	
	open weak var delegate: ExpandedDateRangePickerControllerDelegate?
	
	public init(dateRange: DateRange, hourShift: Int) {
		_dateRange = dateRange
		self.hourShift = hourShift
		super.init(nibName: "ExpandedDateRangePickerController",
			bundle: Bundle(for: ExpandedDateRangePickerController.self))
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
		presetRangeSelector?.selectItem(at: presetRanges.firstIndex(where: { $0 == dateRange }) ?? 0)
	}
	
	@IBAction func presetRangeSelected(_ sender: NSPopUpButton) {
		guard let selectedRange = presetRanges[sender.indexOfSelectedItem] else { return }
		switch selectedRange {
		case .custom:
			dateRange = DateRange.custom(startDate, endDate, hourShift: self.hourShift)
		case .pastDays, .calendarUnit:
			dateRange = selectedRange
		}
	}
}
