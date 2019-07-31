//
//  NSDate_DateRangePicker.swift
//  DateRangePicker
//
//  Created by Daniel Alm on 07.11.15.
//  Copyright © 2015 Daniel Alm. All rights reserved.
//

import Foundation

//! CLEANUP: Migrate these APIs from NSCalendar.Unit to Calendar.Component.
public extension Date {
	func drp_addCalendarUnits(_ count: Int, unit: NSCalendar.Unit, calendar: Calendar = Calendar.current) -> Date? {
		let advancedDate: Date?
		if unit == .quarter {
			// There seems to be a bug where adding one quarter to a date in the 3rd quarter does not return the
			// corresponding date in the 4th quarter. As a workaround, we add 3 months instead.
			advancedDate = (calendar as NSCalendar).date(byAdding: .month, value: 3 * count, to: self, options: [])
		} else {
			advancedDate = (calendar as NSCalendar).date(byAdding: unit, value: count, to: self, options: [])
		}
		return advancedDate
	}
	
	func drp_beginning(ofCalendarUnit unit: NSCalendar.Unit, calendar: Calendar = Calendar.current) -> Date? {
		var reducedDate: NSDate?
		(calendar as NSCalendar).range(of: unit, start: &reducedDate, interval: nil, for: self)
		return reducedDate as Date?
	}
	
	func drp_end(ofCalendarUnit unit: NSCalendar.Unit, calendar: Calendar = Calendar.current,
	                    adjustByOneSecond: Bool = true, returnNextIfAtBoundary: Bool = true) -> Date? {
		guard let startDate = drp_beginning(ofCalendarUnit: unit, calendar: Calendar.current) else { return nil }
		if startDate == self && !adjustByOneSecond && !returnNextIfAtBoundary { return self }
		let result = startDate.drp_addCalendarUnits(1, unit: unit, calendar: calendar)
		return adjustByOneSecond ? result?.addingTimeInterval(-1) : result
	}
	
	func drp_calendarUnits(since: Date, unit: NSCalendar.Unit, calendar: Calendar = Calendar.current) -> Int? {
		guard let fromDate = since.drp_beginning(ofCalendarUnit: unit, calendar: calendar),
			let toDate = self.drp_beginning(ofCalendarUnit: unit, calendar: calendar)
			else { return nil }
		return ((calendar as NSCalendar)
			.components(unit, from: fromDate, to: toDate, options: []) as NSDateComponents)
			.value(forComponent: unit)
	}
	
	// Returns the number of calendar days between the argument and the receiver.
	func drp_daysSince(_ since: Date, calendar: Calendar = Calendar.current) -> Int? {
		return self.drp_calendarUnits(since: since, unit: .day, calendar: calendar)
	}
}

public extension Calendar.Component {
	var isAffectedByHourShift: Bool {
		switch self {
		case .era, .year, .month, .day, .weekday, .weekdayOrdinal, .quarter, .weekOfMonth,
		     .weekOfYear, .yearForWeekOfYear: return true
		case .hour, .minute, .second, .nanosecond, .calendar, .timeZone: return false
		@unknown default: return false
		}
	}
}

public extension Date {
	func drp_adding(_ value: Int, component: Calendar.Component, calendar: Calendar = Calendar.current) -> Date? {
		if component == .quarter {
			// There seems to be a bug where adding one quarter to a date in the 3rd quarter does not return the
			// corresponding date in the 4th quarter. As a workaround, we add 3 months instead.
			return calendar.date(byAdding: .month, value: 3 * value, to: self)
		} else {
			return calendar.date(byAdding: component, value: value, to: self)
		}
	}
	
	func drp_beginning(of component: Calendar.Component, calendar: Calendar = Calendar.current) -> Date? {
		var startDate = self
		var timeInterval: TimeInterval = 0
		guard calendar.dateInterval(of: component, start: &startDate, interval: &timeInterval, for: self) else { return nil }
		return startDate
	}
	
	func drp_end(of component: Calendar.Component, calendar: Calendar = Calendar.current,
	                    returnNextIfAtBoundary: Bool = true) -> Date? {
		guard let startDate = drp_beginning(of: component, calendar: Calendar.current) else { return nil }
		if startDate == self && !returnNextIfAtBoundary { return self }
		return startDate.drp_adding(1, component: component, calendar: calendar)
	}
	
	func drp_settingHour(to value: Int, calendar: Calendar = Calendar.current) -> Date? {
		return calendar.date(bySettingHour: value, minute: 0, second: 0, of: self)
	}
	
	func drp_beginningOfShiftedDay(by shiftedHour: Int, calendar: Calendar = Calendar.current) -> Date? {
		// We could also use calendar.nextDate(after:...) here, but that is significantly slower.
		let modifiedDate = self.drp_settingHour(to: shiftedHour, calendar: calendar)
		if let modifiedDate = modifiedDate, modifiedDate <= self {
			return modifiedDate
		} else {
			return modifiedDate?.drp_adding(-1, component: .day, calendar: calendar)
		}
	}
	
	func drp_beginning(of component: Calendar.Component, hourShift: Int, calendar: Calendar = Calendar.current) -> Date? {
		if !component.isAffectedByHourShift {
			return self.drp_beginning(of: component, calendar: calendar)
		}
		
		return self
			.drp_beginningOfShiftedDay(by: hourShift, calendar: calendar)?
			.drp_beginning(of: component, calendar: calendar)?
			.drp_settingHour(to: hourShift, calendar: calendar)
	}
	
	func drp_end(of component: Calendar.Component, hourShift: Int, calendar: Calendar = Calendar.current) -> Date? {
		if !component.isAffectedByHourShift {
			return self.drp_end(of: component, calendar: calendar)
		}
		
		return self
			.drp_beginning(of: component, hourShift: hourShift, calendar: calendar)?
			.drp_adding(1, component: component, calendar: calendar)
	}
	
	func drp_components(_ component: Calendar.Component, since startDate: Date, calendar: Calendar = Calendar.current) -> Int? {
		guard let fromDate = startDate.drp_beginning(of: component, calendar: calendar),
			let toDate = self.drp_beginning(of: component, calendar: calendar) else { return nil }
		return calendar.dateComponents(Set(arrayLiteral: component), from: fromDate, to: toDate)
			.value(for: component)
	}
}

// Required for backwards compatibility with Objective-C.
public extension NSDate {
	func drp_addCalendarUnits(_ count: Int, unit: NSCalendar.Unit, calendar: Calendar = Calendar.current) -> NSDate? {
		return (self as Date).drp_addCalendarUnits(count, unit: unit, calendar: calendar) as NSDate?
	}
	
	func drp_beginning(ofCalendarUnit unit: NSCalendar.Unit, calendar: Calendar = Calendar.current) -> NSDate? {
		return (self as Date).drp_beginning(ofCalendarUnit: unit, calendar: calendar) as NSDate?
	}
	
	func drp_end(ofCalendarUnit unit: NSCalendar.Unit, calendar: Calendar = Calendar.current) -> NSDate? {
		return (self as Date).drp_end(ofCalendarUnit: unit, calendar: calendar) as NSDate?
	}
	
	func drp_calendarUnits(since: NSDate, unit: NSCalendar.Unit, calendar: Calendar = Calendar.current) -> Int? {
		return (self as Date).drp_calendarUnits(since: since as Date, unit: unit, calendar: calendar)
	}
	
	// Returns the number of calendar days between the argument and the receiver.
	func drp_daysSince(_ since: NSDate, calendar: Calendar = Calendar.current) -> Int? {
		return (self as Date).drp_daysSince(since as Date, calendar: calendar)
	}
}
