//
//  DateRangePickerView.swift
//  DateRangePicker
//
//  Created by Daniel Alm on 07.11.15.
//  Copyright © 2015 Daniel Alm. All rights reserved.
//

import Foundation

@IBDesignable
open class DateRangePickerView : NSControl, ExpandedDateRangePickerControllerDelegate, NSPopoverDelegate {
	fileprivate let segmentedControl: NSSegmentedControl
	fileprivate let dateFormatter = DateFormatter()
	fileprivate var dateRangePickerController: ExpandedDateRangePickerController?
	
	// MARK: - Date properties
	fileprivate var _dateRange: DateRange  // Should almost never be accessed directly
	open var dateRange: DateRange {
		get {
			return _dateRange
		}

		set {
			let restrictedValue = newValue.restrictToDates(minDate as NSDate?, maxDate as NSDate?)
			if _dateRange != restrictedValue {
				self.willChangeValue(forKey: "endDate")
				self.willChangeValue(forKey: "startDate")
				_dateRange = restrictedValue
				self.didChangeValue(forKey: "endDate")
				self.didChangeValue(forKey: "startDate")
				
				if dateRangePickerController?.dateRange != dateRange {
					dateRangePickerController?.dateRange = dateRange
				}
				updateSegmentedControl()
				
				sendAction(action, to: target)
			}
		}
	}
	
	// Can be used for restricting the selectable dates to a specific range.
	open dynamic var minDate: NSDate? {
		didSet {
			dateRangePickerController?.minDate = minDate as Date?
			// Enforces the new date range restriction
			dateRange = _dateRange
			updateSegmentedControl()
		}
	}
	open dynamic var maxDate: NSDate? {
		didSet {
			dateRangePickerController?.maxDate = maxDate as
				Date?
			// Enforces the new date range restriction
			dateRange = _dateRange
			updateSegmentedControl()
		}
	}
	
	open var dateStyle: DateFormatter.Style {
		get {
			return dateFormatter.dateStyle
		}
		
		set {
			dateFormatter.dateStyle = newValue
			updateSegmentedControl()
		}
	}
	
	open var dateRangeString: String {
		return dateRange.dateRangeDescription(dateFormatter)
	}
	
	// MARK: - Objective-C interoperability
	open dynamic var startDate: NSDate {
		get {
			return dateRange.startDate as NSDate
		}
		
		set {
			dateRange = DateRange.custom(newValue as Date, endDate as Date)
		}
	}
	open dynamic var endDate: NSDate {
		get {
			return dateRange.endDate as NSDate
		}
		
		set {
			dateRange = DateRange.custom(startDate as Date, newValue as Date)
		}
	}
	
	open func setStartDate(_ startDate: NSDate, endDate: NSDate) {
		dateRange = .custom(startDate as Date, endDate as Date)
	}
	
	// In Objective-C, the DateRange type isn't available. In order to still persist the picker's
	// date range (e.g. between launches), you can use these functions instead.
	open func dateRangeAsData() -> Data {
		return dateRange.toData() as Data
	}
	open func loadDateRangeFromData(_ data: Data) {
		guard let newRange = DateRange.fromData(data) else { return }
		dateRange = newRange
	}
	
	// MARK: - Other properties
	open var segmentStyle: NSSegmentStyle {
		get {
			return segmentedControl.segmentStyle
		}
		
		set {
			segmentedControl.segmentStyle = newValue
		}
	}
	
	// MARK: - Methods
	open func displayExpandedDatePicker() {
		if dateRangePickerController != nil { return }
		
		let popover = NSPopover()
		popover.behavior = .semitransient
		dateRangePickerController = ExpandedDateRangePickerController(dateRange: dateRange)
		dateRangePickerController?.minDate = minDate as Date?
		dateRangePickerController?.maxDate = maxDate as Date?
		dateRangePickerController?.delegate = self
		popover.contentViewController = dateRangePickerController
		popover.delegate = self
		popover.show(relativeTo: self.bounds, of: self, preferredEdge: .minY)
		updateSegmentedControl()
	}
	
	// MARK: - Initializers
	fileprivate func sharedInit() {
		segmentedControl.segmentCount = 3
		segmentedControl.setLabel("◀", forSegment: 0)
		segmentedControl.setLabel("▶", forSegment: 2)
		segmentedControl.action = #selector(DateRangePickerView.segmentDidChange(_:))
		segmentedControl.autoresizingMask = NSAutoresizingMaskOptions()
		segmentedControl.target = self
		self.addSubview(segmentedControl)
		
		self.dateStyle = .medium
	}
	
	override public init(frame frameRect: NSRect) {
		segmentedControl = NSSegmentedControl()
		_dateRange = .pastDays(7)
		super.init(frame: frameRect)
		sharedInit()
	}
	
	required public init?(coder: NSCoder) {
		segmentedControl = NSSegmentedControl()
		_dateRange = .pastDays(7)
		super.init(coder: coder)
		sharedInit()
	}
	
	// MARK: - NSControl
	// Without this, the control's target and action are not being set on Mavericks.
	// (See http://stackoverflow.com/questions/3889043/nscontrol-subclass-cant-read-the-target)
	override open class func cellClass() -> AnyClass? {
		return NSActionCell.self
	}
	
	// MARK: - Internal
	override open func resizeSubviews(withOldSize size: CGSize) {
		// It would be nice to use Auto Layout instead, but that doesn't play nicely with views in a toolbar.
		let sideButtonWidth: CGFloat = 22
		// Magic number to avoid the segmented control overflowing out of its bounds.
		let unusedControlWidth: CGFloat = 8
		segmentedControl.setWidth(sideButtonWidth, forSegment:0)
		segmentedControl.setWidth(self.bounds.size.width - 2 * sideButtonWidth - unusedControlWidth, forSegment:1)
		segmentedControl.setWidth(sideButtonWidth, forSegment:2)
		segmentedControl.frame = self.bounds
		super.resizeSubviews(withOldSize: size)
	}
	
	func segmentDidChange(_ sender: NSSegmentedControl) {
		switch sender.selectedSegment {
		case 0:
			dateRange = dateRange.previous()
		case 1:
			displayExpandedDatePicker()
		case 2:
			dateRange = dateRange.next()
		default:
			break
		}
	}
	
	fileprivate func updateSegmentedControl() {
		segmentedControl.setLabel(dateRangeString, forSegment: 1)
		
		// Only enable the previous/next buttons if they do not touch outside the date restrictions range already.
		let previousAllowed = minDate != nil ? dateRange.startDate as NSDate != minDate?.drp_beginningOfCalendarUnit(unit: .day) : true
		segmentedControl.setEnabled(previousAllowed, forSegment: 0)
		
		let nextAllowed = maxDate != nil ? dateRange.endDate as NSDate != maxDate?.drp_endOfCalendarUnit(unit: .day) : true
		segmentedControl.setEnabled(nextAllowed, forSegment: 2)
		
		// Display the middle segment as selected while the expanded date range popover is being shown.
		(segmentedControl.cell as? NSSegmentedCell)?.trackingMode = dateRangePickerController != nil ? .selectOne : .momentary
		segmentedControl.selectedSegment = dateRangePickerController != nil ? 1 : -1
	}
	
	// MARK: - ExpandedDateRangePickerControllerDelegate
	open func expandedDateRangePickerControllerDidChangeDateRange(_ controller: ExpandedDateRangePickerController) {
		if controller === dateRangePickerController {
			self.dateRange = controller.dateRange
		}
	}
	
	// MARK: - NSPopoverDelegate
	open func popoverWillClose(_ notification: Notification) {
		guard let popover = notification.object as? NSPopover else { return }
		if popover.contentViewController === dateRangePickerController {
			dateRangePickerController = nil
			updateSegmentedControl()
		}
	}
}
