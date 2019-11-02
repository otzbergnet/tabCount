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

    let settings = SettingsHelper()
    
    @IBOutlet weak var tabCountBox: NSTextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getPreviousMaxTabs()
    }
    
    func getPreviousMaxTabs(){
        let maxTabs = settings.getIntData(key: "maxTabs")
        print(maxTabs)
        if(maxTabs > 0){
            tabCountBox.stringValue = "\(maxTabs)"
        }
        else{
            tabCountBox.stringValue = "10"
            settings.setIntData(key: "maxTabs", data: 10)
        }
        
    }
    
    @IBAction func openSafariExtensionPreferences(_ sender: AnyObject?) {
        SFSafariApplication.showPreferencesForExtension(withIdentifier: "net.otzberg.tabCount-Extension") { error in
            if let _ = error {
                // Insert code to inform the user that something went wrong.
            }
        }
    }

    @IBAction func tabCountSave(_ sender: Any) {
        if let maxTabsFromBox = Int(tabCountBox.stringValue){
            print(maxTabsFromBox)
            settings.setIntData(key: "maxTabs", data: maxTabsFromBox)
        }
        else{
            tabCountBox.stringValue = "10"
        }
    }
    
    
    
}
