//
//  DateErrorLogger.swift
//  DateRangePicker
//
//  Created by Daniel Alm on 22.01.18.
//  Copyright © 2018 Daniel Alm. All rights reserved.
//

import Foundation

public var globalDateErrorLogger: DateErrorLogger?

public protocol DateErrorLogger {
	func logDayStartFailed(for date: Date, calendar: Calendar)
}
