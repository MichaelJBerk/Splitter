//
//  LoadingViewController.swift
//  Splitter
//
//  Created by Michael Berk on 8/18/20.
//  Copyright © 2020 Michael Berk. All rights reserved.
//

import Cocoa

class LoadingViewController: NSViewController, LoadableNib {
	@IBOutlet weak var contentView: NSView!
	
	@IBOutlet weak var imageView: NSImageView!
	@IBOutlet weak var labelView: NSTextField!
	@IBOutlet weak var loadingBar: NSProgressIndicator!
	

	override func viewWillAppear() {
		super.viewWillAppear()
		self.imageView.image = NSImage(named: NSImage.applicationIconName)
		loadingBar.startAnimation(nil)
		
	}
    override func viewDidLoad() {
        super.viewDidLoad()
		
        // Do view setup here.
    }
    
}
