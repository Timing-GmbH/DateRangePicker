//
//  AppDelegate.swift
//  DateRangePickerDemo
//
//  Created by Daniel Alm on 07.11.15.
//  Copyright © 2015 Daniel Alm. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



	func applicationDidFinishLaunching(aNotification: NSNotification) {
		// Insert code here to initialize your application
		if #available(OSX 10.12, *) {
			NSWindow.allowsAutomaticWindowTabbing = false
		} else {
			// Fallback on earlier versions
		}
	}

	func applicationWillTerminate(aNotification: NSNotification) {
		// Insert code here to tear down your application
	}


}

