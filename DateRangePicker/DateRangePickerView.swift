//
//  DateRangePickerView.swift
//  DateRangePicker
//
//  Created by Daniel Alm on 07.11.15.
//  Copyright © 2015 Daniel Alm. All rights reserved.
//

import Cocoa

@IBDesignable
open class DateRangePickerView: NSControl, ExpandedDateRangePickerControllerDelegate, NSPopoverDelegate {
	fileprivate let segmentedControl: NSSegmentedControl
	open let dateFormatter = DateFormatter()
	fileprivate var dateRangePickerController: ExpandedDateRangePickerController?
	
	// MARK: - Date properties
	fileprivate var _dateRange: DateRange  // Should almost never be accessed directly
	open var dateRange: DateRange {
		get {
			return _dateRange
		}

		set {
			let restrictedValue = newValue.restrictTo(minDate: minDate, maxDate: maxDate)
			if _dateRange != restrictedValue {
				self.willChangeValue(forKey: #keyPath(endDate))
				self.willChangeValue(forKey: #keyPath(startDate))
				_dateRange = restrictedValue
				self.didChangeValue(forKey: #keyPath(endDate))
				self.didChangeValue(forKey: #keyPath(startDate))
				
				if dateRangePickerController?.dateRange != dateRange {
					dateRangePickerController?.dateRange = dateRange
				}
				updateSegmentedControl()
				
				sendAction(action, to: target)
			}
		}
	}
	
	@objc open func dayChanged(_ notification: Notification) {
		// If the current date ranged is specified in a relative fashion,
		// it might change on actual day changes, so make sure to notify any observers.
		self.willChangeValue(forKey: #keyPath(endDate))
		self.willChangeValue(forKey: #keyPath(startDate))
		self.didChangeValue(forKey: #keyPath(endDate))
		self.didChangeValue(forKey: #keyPath(startDate))
	}
	
	// Can be used for restricting the selectable dates to a specific range.
	open dynamic var minDate: Date? {
		didSet {
			dateRangePickerController?.minDate = minDate
			// Enforces the new date range restriction
			dateRange = _dateRange
			updateSegmentedControl()
		}
	}
	open dynamic var maxDate: Date? {
		didSet {
			dateRangePickerController?.maxDate = maxDate
			// Enforces the new date range restriction
			dateRange = _dateRange
			updateSegmentedControl()
		}
	}
	
	@available(*, deprecated, message: "Use .dateFormatter directly instead")
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
		return dateRange.dateRangeDescription(withFormatter: dateFormatter)
	}
	
	// MARK: - Objective-C interoperability
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
	
	open override var isEnabled: Bool {
		get { return segmentedControl.isEnabled }
		set { segmentedControl.isEnabled = newValue }
	}
	
	
	private var _touchBarItem: NSObject?
	
	// A touch bar item representing this date picker, with a popover menu to select different date ranges.
	@available(OSX 10.12.2, *)
	open var touchBarItem: NSPopoverTouchBarItem {
		get {
			if _touchBarItem == nil {
				_touchBarItem = makeTouchBarItem()
			}
			
			return _touchBarItem as! NSPopoverTouchBarItem
		}
	}
	
	// The date ranges available from the touch bar item popover.
	// Needs to be set before touchBarItem is accessed.
	open var popoverItemDateRanges: [DateRange?] = [
		.pastDays(7),
		.pastDays(15),
		.pastDays(30),
		nil,
		.calendarUnit(0, .day),
		.calendarUnit(-1, .day),
		nil,
		.calendarUnit(0, .weekOfYear),
		.calendarUnit(0, .month),
		.calendarUnit(0, .year)
	]
	
	// The segmented control used by the touch bar item.
	open fileprivate(set) var touchBarSegment: NSSegmentedControl?
	
	
	open func setStartDate(_ startDate: Date, endDate: Date) {
		dateRange = .custom(startDate, endDate)
	}

	@IBAction open func selectToday(_ sender: AnyObject?) {
		self.dateRange = DateRange.calendarUnit(0, .day)
	}
	
	// In Objective-C, the DateRange type isn't available. In order to still persist the picker's
	// date range (e.g. between launches), you can use these functions instead.
	open func dateRangeAsData() -> Data {
		return dateRange.toData() as Data
	}
	open func loadDateRangeFromData(_ data: Data) {
		guard let newRange = DateRange.from(data: data) else { return }
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
	
	// If true, segmented control's height will be fixed and its vertical offset adjusted
	// to hopefully align it with other buttons in the toolbar.
	@IBInspectable open var optimizeForToolbarDisplay: Bool = false
	
	// MARK: - Methods
	open func makePopover() -> NSPopover {
		let popover = NSPopover()
		popover.behavior = .semitransient
		return popover
	}
	
	open func displayExpandedDatePicker() {
		if dateRangePickerController != nil { return }
		
		let popover = makePopover()
		dateRangePickerController = ExpandedDateRangePickerController(dateRange: dateRange)
		dateRangePickerController?.minDate = minDate
		dateRangePickerController?.maxDate = maxDate
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
		segmentedControl.action = #selector(segmentDidChange(_:))
		segmentedControl.autoresizingMask = NSAutoresizingMaskOptions()
		segmentedControl.target = self
		self.addSubview(segmentedControl)
		
		self.dateFormatter.dateStyle = .medium
		
		NotificationCenter.default.addObserver(self, selector: #selector(dayChanged(_:)), name: NSNotification.Name.NSCalendarDayChanged, object: nil)
		
		// Required to display the proper title from the beginning, even if .dateRange is not changed before displaying
		// the control.
		updateSegmentedControl()
		updateSegmentedControlFrame()
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
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	// MARK: - NSControl
	// Without this, the control's target and action are not being set on Mavericks.
	// (See http://stackoverflow.com/questions/3889043/nscontrol-subclass-cant-read-the-target)
	override open class func cellClass() -> AnyClass? {
		return NSActionCell.self
	}
	
	open func updateSegmentedControlFrame() {
		// It would be nice to use Auto Layout instead, but that doesn't play nicely with views in a toolbar.
		let sideButtonWidth: CGFloat = 22
		// Magic number to avoid the segmented control overflowing out of its bounds.
		let unusedControlWidth: CGFloat = 8
		segmentedControl.setWidth(sideButtonWidth, forSegment: 0)
		segmentedControl.setWidth(self.bounds.size.width - 2 * sideButtonWidth - unusedControlWidth, forSegment: 1)
		segmentedControl.setWidth(sideButtonWidth, forSegment: 2)
		var segmentedControlFrame = self.bounds
		// Ensure that the segmented control is large enough to not be clipped.
		if optimizeForToolbarDisplay {
			segmentedControlFrame.size.height = 25
			if NSScreen.main()?.backingScaleFactor == 2 {
				segmentedControlFrame.origin.y = -0.5
			}
		}
		segmentedControl.frame = segmentedControlFrame
	}
	
	// MARK: - Internal
	override open func resizeSubviews(withOldSize size: CGSize) {
		updateSegmentedControlFrame()
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
		let dateRangeString = self.dateRangeString
		segmentedControl.setLabel(dateRangeString, forSegment: 1)
		touchBarSegment?.setLabel(dateRangeString, forSegment: 1)
		
		// Only enable the previous/next buttons if they do not touch outside the date restrictions range already.
		let previousAllowed = minDate != nil ? dateRange.startDate != minDate?.drp_beginning(ofCalendarUnit: .day) : true
		segmentedControl.setEnabled(previousAllowed, forSegment: 0)
		touchBarSegment?.setEnabled(previousAllowed, forSegment: 0)
		
		let nextAllowed = maxDate != nil ? dateRange.endDate != maxDate?.drp_end(ofCalendarUnit: .day) : true
		segmentedControl.setEnabled(nextAllowed, forSegment: 2)
		touchBarSegment?.setEnabled(nextAllowed, forSegment: 2)
		
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

@available(OSX 10.12.2, *)
extension DateRangePickerView: NSTouchBarDelegate {
	public static let touchBarItemIdentifier = NSTouchBarItemIdentifier("de.danielalm.DateRangePicker.DateRangePickerViewTouchBarItem")
	
	private static let popoverItemIdentifierPrefix = "de.danielalm.DateRangePicker.DateRangePickerViewPopoverTouchBar."
	
	fileprivate func makeTouchBarItem() -> NSTouchBarItem {
		let segment = NSSegmentedControl(labels: ["", "", ""], trackingMode: .momentary,
		                                 target: self, action: #selector(DateRangePickerView.touchBarSegmentPressed(_:)))
		segment.setImage(NSImage(named: NSImageNameTouchBarGoBackTemplate)!, forSegment: 0)
		segment.setImage(NSImage(named: NSImageNameTouchBarGoForwardTemplate)!, forSegment: 2)
		segment.setWidth(30, forSegment: 0)
		segment.setWidth(250, forSegment: 1)
		segment.setWidth(30, forSegment: 2)
		self.touchBarSegment = segment
		touchBarSegment?.segmentStyle = .separated
		updateSegmentedControl()
		
		let item = NSPopoverTouchBarItem(identifier: DateRangePickerView.touchBarItemIdentifier)
		item.collapsedRepresentation = segment
		item.customizationLabel = NSLocalizedString("Date Range", bundle: getBundle(),
		                                            comment: "Customization label for the Date Range picker.")
		
		item.popoverTouchBar.defaultItemIdentifiers = popoverItemDateRanges.map {
			guard let dateRange = $0 else { return NSTouchBarItemIdentifier.flexibleSpace }
			// This does create very ugly identifiers, but they are sufficient for our use case.
			return NSTouchBarItemIdentifier(DateRangePickerView.popoverItemIdentifierPrefix + String(describing: dateRange))
		}
		item.popoverTouchBar.delegate = self
		
		return item
	}
	
	func touchBarSegmentPressed(_ sender: NSSegmentedControl) {
		switch sender.selectedSegment {
		case 0: dateRange = dateRange.previous()
		case 1: touchBarItem.showPopover(sender)
		case 2: dateRange = dateRange.next()
		default: break
		}
	}
	
	public func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItemIdentifier) -> NSTouchBarItem? {
		if identifier.rawValue.hasPrefix(DateRangePickerView.popoverItemIdentifierPrefix) {
			let identifierSuffix = identifier.rawValue
				.substring(from: DateRangePickerView.popoverItemIdentifierPrefix.endIndex)
			// Not very efficient, but more than fast enough for our purposes.
			guard let (itemIndex, dateRange) = (popoverItemDateRanges
				.enumerated()
				.first {
					guard let dateRange = $0.1 else { return false }
					return String(describing: dateRange) == identifierSuffix }),
				let dateRangeTitle = dateRange?.shortTitle else { return nil }
			
			let button = NSButton(title: dateRangeTitle,
			                      target: self, action: #selector(DateRangePickerView.popoverItemPressed(_:)))
			button.tag = itemIndex
			
			let item = NSCustomTouchBarItem(identifier: identifier)
			item.view = button
			return item
		}
		return nil
	}
	
	func popoverItemPressed(_ sender: NSButton) {
		guard sender.tag >= 0 && sender.tag < popoverItemDateRanges.count,
			let dateRange = popoverItemDateRanges[sender.tag] else { return }
		self.dateRange = dateRange
		touchBarItem.dismissPopover(sender)
	}
}
