//
//  AppDelegate.swift
//  tabCount
//
//  Created by Claus Wolf on 02.11.19.
//  Copyright © 2019 Claus Wolf. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool{
        return true
    }
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        NSAppleEventManager
            .shared()
            .setEventHandler(
                self,
                andSelector: #selector(handleURL(event:reply:)),
                forEventClass: AEEventClass(kInternetEventClass),
                andEventID: AEEventID(kAEGetURL)
            )

    }

    @objc func handleURL(event: NSAppleEventDescriptor, reply: NSAppleEventDescriptor) {
        if ((event.paramDescriptor(forKeyword: keyDirectObject)?.stringValue?.removingPercentEncoding) != nil) {
            let myTabBar = NSApplication.shared.mainWindow?.windowController?.contentViewController as! NSTabViewController
            myTabBar.tabView.selectTabViewItem(at: 1)
        }
    }
}
