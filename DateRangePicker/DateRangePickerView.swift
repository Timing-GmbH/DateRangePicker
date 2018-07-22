//
//  DateRangePickerView.swift
//  DateRangePicker
//
//  Created by Daniel Alm on 07.11.15.
//  Copyright © 2015 Daniel Alm. All rights reserved.
//

import Cocoa

@objc public protocol DateRangePickerViewDelegate {
	func dateRangePickerView(
		_ dateRangePickerView: DateRangePickerView,
		willPresentExpandedDateRangePickerController expandedDateRangePickerController: ExpandedDateRangePickerController)
	func dateRangePickerViewDidCloseExpandedDateRangePickerController(_ dateRangePickerView: DateRangePickerView)
}

public protocol DateRangePickerViewDelegateSwiftOnly: DateRangePickerViewDelegate {
	func dateRangePickerView(_ dateRangePickerView: DateRangePickerView,
	                         descriptionFor dateRange: DateRange, formatter: DateFormatter) -> String
}

@IBDesignable
open class DateRangePickerView: NSControl, ExpandedDateRangePickerControllerDelegate, NSPopoverDelegate {
	fileprivate let segmentedControl: NSSegmentedControl
	public let dateFormatter = DateFormatter()
	fileprivate var dateRangePickerController: ExpandedDateRangePickerController?
	
	open weak var delegate: DateRangePickerViewDelegate?
	
	// MARK: - Date properties
	fileprivate var _dateRange: DateRange  // Should almost never be accessed directly
	open var dateRange: DateRange {
		get {
			return _dateRange
		}

		set {
			var restrictedValue = newValue.restrictTo(minDate: minDate, maxDate: maxDate)
			restrictedValue.hourShift = self.hourShift
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
	
	@objc open dynamic var hourShift: Int = 0 {
		didSet {
			dateRange.hourShift = hourShift
			dateRangePickerController?.hourShift = hourShift
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
	@objc open dynamic var minDate: Date? {
		didSet {
			dateRangePickerController?.minDate = minDate
			// Enforces the new date range restriction
			dateRange = _dateRange
			updateSegmentedControl()
		}
	}
	@objc open dynamic var maxDate: Date? {
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
	
	@objc open var dateRangeString: String {
		if let delegate = delegate as? DateRangePickerViewDelegateSwiftOnly {
			return delegate.dateRangePickerView(self, descriptionFor: dateRange, formatter: dateFormatter)
		}
		return dateRange.dateRangeDescription(withFormatter: dateFormatter)
	}
	
	// MARK: - Objective-C interoperability
	@objc open dynamic var startDate: Date {
		get {
			return dateRange.startDate
		}
		
		set {
			dateRange = DateRange.custom(newValue, endDate, hourShift: self.hourShift)
		}
	}
	@objc open dynamic var endDate: Date {
		get {
			return dateRange.endDate
		}
		
		set {
			dateRange = DateRange.custom(startDate, newValue, hourShift: self.hourShift)
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
	open var popoverItemDateRanges: [DateRange?] {
		return [
			.pastDays(7, hourShift: self.hourShift),
			.pastDays(15, hourShift: self.hourShift),
			.pastDays(30, hourShift: self.hourShift),
			nil,
			.calendarUnit(0, .day, hourShift: self.hourShift),
			.calendarUnit(-1, .day, hourShift: self.hourShift),
			nil,
			.calendarUnit(0, .weekOfYear, hourShift: self.hourShift),
			.calendarUnit(0, .month, hourShift: self.hourShift),
			.calendarUnit(0, .year, hourShift: self.hourShift)
		]
	}
	
	// The segmented control used by the touch bar item.
	open fileprivate(set) var touchBarSegment: NSSegmentedControl?
	
	
	open func setStartDate(_ startDate: Date, endDate: Date) {
		dateRange = .custom(startDate, endDate, hourShift: self.hourShift)
	}

	@IBAction open func selectToday(_ sender: AnyObject?) {
		self.dateRange = DateRange.calendarUnit(0, .day, hourShift: self.hourShift)
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
	@objc open var segmentStyle: NSSegmentedControl.Style {
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
		popover.behavior = .transient
		return popover
	}
	
	open func displayExpandedDatePicker() {
		if dateRangePickerController != nil { return }
		
		let popover = makePopover()
		let controller = ExpandedDateRangePickerController(dateRange: dateRange, hourShift: hourShift)
		controller.minDate = minDate
		controller.maxDate = maxDate
		controller.delegate = self
		self.dateRangePickerController = controller
		
		delegate?.dateRangePickerView(self, willPresentExpandedDateRangePickerController: controller)
		
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
		segmentedControl.autoresizingMask = NSView.AutoresizingMask()
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
		_dateRange = .pastDays(7, hourShift: 0)
		super.init(frame: frameRect)
		sharedInit()
	}
	
	required public init?(coder: NSCoder) {
		segmentedControl = NSSegmentedControl()
		_dateRange = .pastDays(7, hourShift: 0)
		super.init(coder: coder)
		sharedInit()
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	// MARK: - NSControl
	// Without this, the control's target and action are not being set on Mavericks.
	// (See http://stackoverflow.com/questions/3889043/nscontrol-subclass-cant-read-the-target)
	override open class var cellClass: AnyClass? {
		get { return NSActionCell.self }
		set { }
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
			if self.window?.screen?.backingScaleFactor == 2 {
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
	
	@objc func segmentDidChange(_ sender: NSSegmentedControl) {
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
	
	open func updateSegmentedControl() {
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
			
			delegate?.dateRangePickerViewDidCloseExpandedDateRangePickerController(self)
		}
	}
	
	override open func viewDidChangeBackingProperties() {
		super.viewDidChangeBackingProperties()
		updateSegmentedControlFrame()
	}
}

@available(OSX 10.12.2, *)
extension DateRangePickerView: NSTouchBarDelegate {
	public static let touchBarItemIdentifier = NSTouchBarItem.Identifier("de.danielalm.DateRangePicker.DateRangePickerViewTouchBarItem")
	
	private static let popoverItemIdentifierPrefix = "de.danielalm.DateRangePicker.DateRangePickerViewPopoverTouchBar."
	
	fileprivate func makeTouchBarItem() -> NSTouchBarItem {
		let segment = NSSegmentedControl(labels: ["", "", ""], trackingMode: .momentary,
		                                 target: self, action: #selector(DateRangePickerView.touchBarSegmentPressed(_:)))
		segment.setImage(NSImage(named: NSImage.touchBarGoBackTemplateName)!, forSegment: 0)
		segment.setImage(NSImage(named: NSImage.touchBarGoForwardTemplateName)!, forSegment: 2)
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
			guard let dateRange = $0 else { return .flexibleSpace }
			// This does create very ugly identifiers, but they are sufficient for our use case.
			return NSTouchBarItem.Identifier(DateRangePickerView.popoverItemIdentifierPrefix + String(describing: dateRange))
		}
		item.popoverTouchBar.delegate = self
		
		return item
	}
	
	@objc func touchBarSegmentPressed(_ sender: NSSegmentedControl) {
		switch sender.selectedSegment {
		case 0: dateRange = dateRange.previous()
		case 1: touchBarItem.showPopover(sender)
		case 2: dateRange = dateRange.next()
		default: break
		}
	}
	
	public func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
		if identifier.rawValue.hasPrefix(DateRangePickerView.popoverItemIdentifierPrefix) {
			let identifierSuffix = identifier.rawValue[DateRangePickerView.popoverItemIdentifierPrefix.endIndex...]
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
	
	@objc func popoverItemPressed(_ sender: NSButton) {
		guard sender.tag >= 0 && sender.tag < popoverItemDateRanges.count,
			let dateRange = popoverItemDateRanges[sender.tag] else { return }
		self.dateRange = dateRange
		touchBarItem.dismissPopover(sender)
	}
}
