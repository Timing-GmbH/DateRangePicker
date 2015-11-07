//
//  ViewController.swift
//  DateRangePickerDemo
//
//  Created by Daniel Alm on 07.11.15.
//  Copyright © 2015 Daniel Alm. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewDidAppear() {
		self.view.window?.titleVisibility = .Hidden
	}

	override var representedObject: AnyObject? {
		didSet {
		// Update the view, if already loaded.
		}
	}


}

