//
//  DateRangePickerView.swift
//  DateRangePicker
//
//  Created by Daniel Alm on 07.11.15.
//  Copyright © 2015 Daniel Alm. All rights reserved.
//

import Foundation

@IBDesignable
public class DateRangePickerView : NSControl, ExpandedDateRangePickerControllerDelegate, NSPopoverDelegate {
	private let segmentedControl: NSSegmentedControl
	private let dateFormatter = NSDateFormatter()
	private var dateRangePickerController: ExpandedDateRangePickerController?
	
	// MARK: - Date properties
	private var _dateRange: DateRange
	public var dateRange: DateRange {
		get {
			return _dateRange
		}

		set {
			let restrictedValue = newValue.restrictToDates(minDate, maxDate)
			if _dateRange != restrictedValue {
				self.willChangeValueForKey("endDate")
				self.willChangeValueForKey("startDate")
				_dateRange = restrictedValue
				self.didChangeValueForKey("endDate")
				self.didChangeValueForKey("startDate")
				
				if dateRangePickerController?.dateRange != dateRange {
					dateRangePickerController?.dateRange = dateRange
				}
				updateSegmentedControl()
				
				sendAction(action, to: target)
			}
		}
	}
	
	// Can be used for restricting the selectable dates to a specific range.
	public dynamic var minDate: NSDate? {
		didSet {
			dateRangePickerController?.minDate = minDate
			// Enforces the new date range restriction
			dateRange = _dateRange
			updateSegmentedControl()
		}
	}
	public dynamic var maxDate: NSDate? {
		didSet {
			dateRangePickerController?.maxDate = maxDate
			// Enforces the new date range restriction
			dateRange = _dateRange
			updateSegmentedControl()
		}
	}
	
	public var dateStyle: NSDateFormatterStyle {
		get {
			return dateFormatter.dateStyle
		}
		
		set {
			dateFormatter.dateStyle = newValue
			updateSegmentedControl()
		}
	}
	
	public var dateRangeString: String {
		return "\(dateFormatter.stringFromDate(startDate)) - \(dateFormatter.stringFromDate(endDate))"
	}
	
	// MARK: - Objective-C interoperability
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
	
	public func setStartDate(startDate: NSDate, endDate: NSDate) {
		_dateRange = .Custom(startDate, endDate)
	}
	
	// In Objective-C, the DateRange type isn't available. In order to still persist the picker's
	// date range (e.g. between launches), you can use these functions instead.
	public func dateRangeAsData() -> NSData {
		return dateRange.toData()
	}
	public func loadDateRangeFromData(data: NSData) {
		guard let newRange = DateRange.fromData(data) else { return }
		dateRange = newRange
	}
	
	// MARK: - Other properties
	public var segmentStyle: NSSegmentStyle {
		get {
			return segmentedControl.segmentStyle
		}
		
		set {
			segmentedControl.segmentStyle = newValue
		}
	}
	
	// MARK: - Methods
	public func displayExpandedDatePicker() {
		if dateRangePickerController != nil { return }
		
		let popover = NSPopover()
		popover.behavior = .Semitransient
		dateRangePickerController = ExpandedDateRangePickerController(dateRange: dateRange)
		dateRangePickerController?.minDate = minDate
		dateRangePickerController?.maxDate = maxDate
		dateRangePickerController?.delegate = self
		popover.contentViewController = dateRangePickerController
		popover.delegate = self
		popover.showRelativeToRect(self.bounds, ofView: self, preferredEdge: .MinY)
		updateSegmentedControl()
	}
	
	// MARK: - Initializers
	private func sharedInit() {
		segmentedControl.segmentCount = 3
		segmentedControl.setLabel("◀", forSegment: 0)
		segmentedControl.setLabel("▶", forSegment: 2)
		segmentedControl.action = "segmentDidChange:"
		segmentedControl.autoresizingMask = [.ViewNotSizable]
		segmentedControl.target = self
		self.addSubview(segmentedControl)
		
		self.dateStyle = .MediumStyle
	}
	
	override public init(frame frameRect: NSRect) {
		segmentedControl = NSSegmentedControl()
		_dateRange = .PastDays(7)
		super.init(frame: frameRect)
		sharedInit()
	}
	
	required public init?(coder: NSCoder) {
		segmentedControl = NSSegmentedControl()
		_dateRange = .PastDays(7)
		super.init(coder: coder)
		sharedInit()
	}
	
	// MARK: - Internal
	override public func layout() {
		let sideButtonWidth: CGFloat = 22
		// Magic number to avoid the segmented control overflowing out of its bounds.
		let unusedControlWidth: CGFloat = 8
		segmentedControl.setWidth(sideButtonWidth, forSegment:0)
		segmentedControl.setWidth(self.bounds.size.width - 2 * sideButtonWidth - unusedControlWidth, forSegment:1)
		segmentedControl.setWidth(sideButtonWidth, forSegment:2)
		segmentedControl.frame = self.bounds
		super.layout()
	}
	
	func segmentDidChange(sender: NSSegmentedControl) {
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
	
	private func updateSegmentedControl() {
		segmentedControl.setLabel(dateRangeString, forSegment: 1)
		
		// Only enable the previous/next buttons if they do not touch outside the date restrictions range already.
		let previousAllowed = minDate != nil ? dateRange.startDate != minDate?.drp_beginningOfCalendarUnit(.Day) : true
		segmentedControl.setEnabled(previousAllowed, forSegment: 0)
		
		let nextAllowed = maxDate != nil ? dateRange.endDate != maxDate?.drp_endOfCalendarUnit(.Day) : true
		segmentedControl.setEnabled(nextAllowed, forSegment: 2)
		
		// Display the middle segment as selected while the expanded date range popover is being shown.
		(segmentedControl.cell as? NSSegmentedCell)?.trackingMode = dateRangePickerController != nil ? .SelectOne : .Momentary
		segmentedControl.selectedSegment = dateRangePickerController != nil ? 1 : -1
	}
	
	// MARK: - ExpandedDateRangePickerControllerDelegate
	public func expandedDateRangePickerControllerDidChangeDateRange(controller: ExpandedDateRangePickerController) {
		if controller === dateRangePickerController {
			self.dateRange = controller.dateRange
		}
	}
	
	// MARK: - NSPopoverDelegate
	public func popoverWillClose(notification: NSNotification) {
		guard let popover = notification.object as? NSPopover else { return }
		if popover.contentViewController === dateRangePickerController {
			dateRangePickerController = nil
			updateSegmentedControl()
		}
	}
}
