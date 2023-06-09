//
//  DateRangeButton.swift
//  DateRangePicker
//
//  Created by Daniel Alm on 09.02.21.
//  Copyright © 2021 Daniel Alm. All rights reserved.
//

import AppKit

class DateRangeButtonCell: NSButtonCell {
	static let horizontalInset: CGFloat = 7
	static let verticalInset: CGFloat = 3
	static let cornerRadius: CGFloat = {
		if #available(OSX 11.0, *) {
			return 5
		} else {
			return 4
		}
	}()

	override var focusRingType: NSFocusRingType {
		get { .none }
		set { }
	}

	override var attributedTitle: NSAttributedString {
		get {
			NSAttributedString(
				string: self.title,
				attributes: [
					.font: self.font!,
					.foregroundColor: self.state == .on
						? NSColor.selectedMenuItemTextColor
						: NSColor.labelColor,
				]
			)
		}
		set { }
	}

	override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
		if self.state == .on {
			NSColor.selectedMenuItemColor.setFill()
			let path = NSBezierPath(roundedRect: cellFrame,
									xRadius: DateRangeButtonCell.cornerRadius, yRadius: DateRangeButtonCell.cornerRadius)
			path.fill()
		}

		var titleOrigin = cellFrame.origin
		titleOrigin.x += DateRangeButtonCell.horizontalInset
		titleOrigin.y += DateRangeButtonCell.verticalInset
		self.attributedTitle.draw(at: titleOrigin)
	}

	override func drawFocusRingMask(withFrame cellFrame: NSRect, in controlView: NSView) {
		let path = NSBezierPath(roundedRect: cellFrame,
								xRadius: DateRangeButtonCell.cornerRadius, yRadius: DateRangeButtonCell.cornerRadius)
		path.fill()
	}
}

class DateRangeButton: NSButton {
	var dateRange: DateRange?

	override class var cellClass: AnyClass? {
		get { DateRangeButtonCell.self }
		set { }
	}

	override public func resetCursorRects() {
		super.resetCursorRects()

		self.addCursorRect(self.bounds, cursor: .pointingHand)
	}

	override var intrinsicContentSize: NSSize {
		var result = super.intrinsicContentSize
		result.height = 15 + 2 * DateRangeButtonCell.verticalInset
		return result
	}
}
