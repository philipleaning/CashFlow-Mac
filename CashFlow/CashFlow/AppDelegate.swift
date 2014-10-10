//
//  AppDelegate.swift
//  CashFlow
//
//  Created by Alexandre Lopoukhine on 05/10/2014.
//  Copyright (c) 2014 bluetatami. All rights reserved.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var bottomViewHeightConstraint: NSLayoutConstraint!
    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        // Insert code here to initialize your application
        
        topViewHeightConstraint.constant = 30
        bottomViewHeightConstraint.constant = 30
    }

    func applicationWillTerminate(aNotification: NSNotification?) {
        // Insert code here to tear down your application
    }


}

