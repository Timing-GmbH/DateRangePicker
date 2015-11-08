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
		
		preferredContentSize = view.bounds.size
	}
	
	override func viewDidAppear() {
		self.view.window?.titleVisibility = .Hidden
	}
}

