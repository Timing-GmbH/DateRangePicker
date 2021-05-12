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

fileprivate class SolidBackgroundView: NSView {
	var backgroundColor: NSColor?

	convenience init() {
		self.init(frame: .zero)
		self.wantsLayer = true
	}

	convenience init(backgroundColor: NSColor) {
		self.init(frame: .zero)
		self.wantsLayer = true
		self.backgroundColor = backgroundColor
	}

	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		self.wantsLayer = true
	}

	required init?(coder decoder: NSCoder) {
		super.init(coder: decoder)
		self.wantsLayer = true
	}

	static func horizontalSeparator(backgroundColor: NSColor = .gridColor, height: CGFloat = 1) -> SolidBackgroundView {
		let result = SolidBackgroundView(backgroundColor: backgroundColor)
		result.translatesAutoresizingMaskIntoConstraints = false
		result.heightAnchor.constraint(equalToConstant: height).isActive = true
		return result
	}

	static func verticalSeparator(backgroundColor: NSColor = .gridColor, width: CGFloat = 1) -> SolidBackgroundView {
		let result = SolidBackgroundView(backgroundColor: backgroundColor)
		result.translatesAutoresizingMaskIntoConstraints = false
		result.widthAnchor.constraint(equalToConstant: width).isActive = true
		return result
	}

	override var wantsUpdateLayer: Bool { true }

	override func updateLayer() {
		self.layer?.backgroundColor = backgroundColor?.cgColor
	}
}


open class ExpandedDateRangePickerController: NSViewController {
	@IBOutlet var presetColumnStackView: NSStackView?
	@IBOutlet var rhsStackView: NSStackView?
	@IBOutlet var startDateCalendarPicker: DoubleClickDateRangePicker?
	@IBOutlet var endDateCalendarPicker: DoubleClickDateRangePicker?

	open var auxiliaryView: NSView? {
		willSet { auxiliaryView?.removeFromSuperview() }
		didSet {
			// Ensure that the view has been loaded.
			_ = self.view

			if let auxiliaryView = auxiliaryView {
				rhsStackView?.insertArrangedSubview(auxiliaryView, at: 0)
			}
		}
	}
	
	var presetRanges: [[DateRange?]] {
		[
			[
				.pastDays(7, hourShift: self.hourShift),
				.pastDays(15, hourShift: self.hourShift),
				.pastDays(30, hourShift: self.hourShift),
				.pastDays(90, hourShift: self.hourShift),
				.pastDays(365, hourShift: self.hourShift),
			],
			[
				.calendarUnit(0, .day, hourShift: self.hourShift),
				.calendarUnit(0, .weekOfYear, hourShift: self.hourShift),
				.calendarUnit(0, .month, hourShift: self.hourShift),
				.calendarUnit(0, .quarter, hourShift: self.hourShift),
				.calendarUnit(0, .year, hourShift: self.hourShift),
				nil,
				.calendarUnit(-1, .day, hourShift: self.hourShift),
				.calendarUnit(-1, .weekOfYear, hourShift: self.hourShift),
				.calendarUnit(-1, .month, hourShift: self.hourShift),
			]
		]
	}

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

			self.updateButtonStates(selectedRange: dateRange)
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

	private func updateButtonStates(selectedRange: DateRange) {
		guard let presetColumnStackView = self.presetColumnStackView else { return }

		for subview in presetColumnStackView.arrangedSubviews {
			guard let column = subview as? NSStackView else { continue }
			for innerSubview in column.arrangedSubviews {
				guard let button = innerSubview as? DateRangeButton else { continue }
				button.state = button.dateRange == selectedRange ? .on : .off
			}
		}
	}

	private func preparePresetColumnStackView() {
		guard let presetColumnStackView = self.presetColumnStackView else { return }

		var previousColumn: NSStackView?
		for ranges in self.presetRanges {
			let column = NSStackView()
			column.alignment = .leading
			column.orientation = .vertical
			column.spacing = 0
			var previousWasSpacer = false
			for range in ranges {
				guard let range = range,
					  let title = range.title else {
					previousWasSpacer = true
					continue
				}

				let button = DateRangeButton()
				button.title = title
				button.bezelStyle = .inline
				button.dateRange = range
				button.target = self
				button.action = #selector(presetRangeSelected(_:))

				if previousWasSpacer,
				   let previousSubview = column.subviews.last {
					column.setCustomSpacing(8, after: previousSubview)
					previousWasSpacer = false
				}
				column.addArrangedSubview(button)

				column.widthAnchor.constraint(equalTo: button.widthAnchor).isActive = true
			}

			presetColumnStackView.addArrangedSubview(column)
			var separatorColor: NSColor?
			if #available(OSX 10.14, *) {
				// In other contexts, `.gridColor` seems to work fine for uses like this, but in this particular case it
				// appears too weak (possibly because of the popover's vibrancy).
				separatorColor = NSColor(named: "DateRangePicker_separator")
			}
			let separator = SolidBackgroundView.verticalSeparator(
				backgroundColor: separatorColor ?? NSColor(calibratedWhite: 0, alpha: 0.2))
			presetColumnStackView.addArrangedSubview(separator)
			separator.heightAnchor.constraint(equalTo: presetColumnStackView.heightAnchor).isActive = true

			if let previousColumn = previousColumn {
				previousColumn.widthAnchor.constraint(equalTo: column.widthAnchor).isActive = true
			}
			previousColumn = column
		}

		updateButtonStates(selectedRange: self.dateRange)
	}
	
	open override func awakeFromNib() {
		super.awakeFromNib()

		self.preparePresetColumnStackView()

		// Allow selecting a single date with a double-click on one of the calendar pickers.
		self.startDateCalendarPicker?.doubleAction = #selector(startDateDoubleClicked(_:))
		self.endDateCalendarPicker?.doubleAction = #selector(endDateDoubleClicked(_:))
	}
	
	@IBAction func presetRangeSelected(_ sender: Any?) {
		guard let selectedRange = (sender as? DateRangeButton)?.dateRange else { return }

		switch selectedRange {
		case .custom:
			dateRange = DateRange.custom(startDate, endDate, hourShift: self.hourShift)
		case .pastDays, .calendarUnit:
			dateRange = selectedRange
		}
	}

	@IBAction func startDateDoubleClicked(_ sender: Any?) {
		self.dateRange = .custom(startDate, startDate, hourShift: hourShift)
	}

	@IBAction func endDateDoubleClicked(_ sender: Any?) {
		self.dateRange = .custom(endDate, endDate, hourShift: hourShift)
	}
}
