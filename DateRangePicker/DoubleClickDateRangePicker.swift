//
//  DoubleClickDateRangePicker.swift
//  DateRangePicker
//
//  Created by Daniel Alm on 12.05.21.
//  Copyright © 2021 Daniel Alm. All rights reserved.
//

import Foundation

open class DoubleClickDateRangePicker: NSDatePicker {
	open var doubleAction: Selector?

	// For some reason, `mouseUp` does not get called on this control. However, given that we are only interested in
	// double-click events, `mouseDown` should also be fine.
	open override func mouseDown(with event: NSEvent) {
		super.mouseDown(with: event)

		if event.clickCount == 2 {
			self.sendAction(doubleAction, to: self.target)
		}
	}
}
