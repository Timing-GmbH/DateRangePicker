//
//  DateRangePickerView.swift
//  DateRangePicker
//
//  Created by Daniel Alm on 07.11.15.
//  Copyright © 2015 Daniel Alm. All rights reserved.
//

import Foundation

@IBDesignable
public class DateRangePickerView : NSControl {
	let segmentedControl: NSSegmentedControl
	let dateFormatter = NSDateFormatter()
	
	public var startDate: NSDate {
		didSet {
			updateSegmentedControl()
		}
	}
	public var endDate: NSDate {
		didSet {
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
		get {
			return "\(dateFormatter.stringFromDate(startDate)) - \(dateFormatter.stringFromDate(endDate))"
		}
	}
	
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
	}
	
	func updateSegmentedControl() {
		segmentedControl.setLabel(dateRangeString, forSegment: 1)
	}
	
	required public init?(coder: NSCoder) {
		segmentedControl = NSSegmentedControl()
		segmentedControl.segmentStyle = .TexturedRounded
		segmentedControl.segmentCount = 3
		segmentedControl.setLabel("◀", forSegment: 0)
		segmentedControl.setLabel("▶", forSegment: 2)
		segmentedControl.action = "segmentDidChange:"
		segmentedControl.autoresizingMask = [.ViewNotSizable]
		(segmentedControl.cell as? NSSegmentedCell)?.trackingMode = .Momentary
		
		endDate = NSDate()
		
		let calendar = NSCalendar.currentCalendar()
		let components = NSDateComponents()
		components.weekOfYear = 1
		components.hour = 12
		startDate = calendar.dateByAddingUnit(.Day, value: -7, toDate: endDate, options: [])!
		
		super.init(coder: coder)
		segmentedControl.target = self
		self.addSubview(segmentedControl)
		
		self.dateStyle = .MediumStyle
	}
}
