//
//  ViewController.swift
//  tabCount
//
//  Created by Claus Wolf on 02.11.19.
//  Copyright © 2019 Claus Wolf. All rights reserved.
//

import Cocoa
import SafariServices.SFSafariApplication

class ViewController: NSViewController {

    @IBAction func openSafariExtensionPreferences(_ sender: AnyObject?) {
        SFSafariApplication.showPreferencesForExtension(withIdentifier: "net.otzberg.tabCount-Extension") { error in
            if let _ = error {
                // Insert code to inform the user that something went wrong.
            }
        }
    }
    
    
}
