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
    @IBOutlet weak var windowCountCheck: NSButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getPreviousMaxTabs()
        getShowWindowState()
    }
    
    func getPreviousMaxTabs(){
        let maxTabs = settings.getIntData(key: "maxTabs")
        if(maxTabs > 0){
            tabCountBox.stringValue = "\(maxTabs)"
        }
        else{
            tabCountBox.stringValue = "10"
            settings.setIntData(key: "maxTabs", data: 10)
        }
        
    }
    
    func getShowWindowState(){
        let windowState = settings.getBoolData(key: "window")
        if(windowState){
            windowCountCheck.state = .on
        }
        else{
            windowCountCheck.state = .off
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
            if(maxTabsFromBox > 0 && maxTabsFromBox < 100){
               settings.setIntData(key: "maxTabs", data: maxTabsFromBox)
            }
            else{
                tabCountBox.stringValue = "10"
            }
            
        }
        else{
            tabCountBox.stringValue = "10"
        }
    }
    
    
    @IBAction func showWindowCount(_ sender: NSButton) {
        if(sender.state == .on){
            settings.setBoolData(key: "window", data: true)
        }
        else{
            settings.setBoolData(key: "window", data: false)
        }
    }
    
    
}
