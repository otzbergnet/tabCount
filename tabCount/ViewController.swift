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
    @IBOutlet weak var windowCountBox: NSTextField!
    
    @IBOutlet weak var windowCountCheck: NSButton!
    @IBOutlet weak var tabCountCheck: NSButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
        getPreviousMaxTabs()
        getPreviousMaxWindows()
        getShowWindowState()
    }
    
    func initialSetup(){
        let previousSetup = settings.getBoolData(key: "setup")
        if(!previousSetup){
            settings.setBoolData(key: "tab", data: true)
            settings.setBoolData(key: "window", data: false)
            settings.setBoolData(key: "setup", data: true)
        }
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
    
    func getPreviousMaxWindows(){
        let maxWindows = settings.getIntData(key: "maxWindows")
        if(maxWindows > 0){
            windowCountBox.stringValue = "\(maxWindows)"
        }
        else{
            windowCountBox.stringValue = "3"
            settings.setIntData(key: "maxWindows", data: 3)
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
    
    func getShowTabState(){
        let tabState = settings.getBoolData(key: "tab")
        if(tabState){
            tabCountCheck.state = .on
        }
        else{
            tabCountCheck.state = .off
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
        if let maxWindowsFromBox = Int(windowCountBox.stringValue){
            if(maxWindowsFromBox > 0 && maxWindowsFromBox < 25){
               settings.setIntData(key: "maxWindows", data: maxWindowsFromBox)
            }
            else{
                windowCountBox.stringValue = "3"
            }
            
        }
        else{
            windowCountBox.stringValue = "3"
        }
    }
    
    @IBAction func windowCountSave(_ sender: Any) {
        if let maxWindowsFromBox = Int(windowCountBox.stringValue){
            if(maxWindowsFromBox > 0 && maxWindowsFromBox < 25){
               settings.setIntData(key: "maxWindows", data: maxWindowsFromBox)
            }
            else{
                windowCountBox.stringValue = "3"
            }
            
        }
        else{
            windowCountBox.stringValue = "3"
        }
    }
    
    
       
    
    
    @IBAction func saveWindowCount(_ sender: NSButton) {
        if(sender.state == .on){
            settings.setBoolData(key: "window", data: true)
        }
        else{
            settings.setBoolData(key: "window", data: false)
        }
        
    }
    
    @IBAction func saveTabCount(_ sender: NSButton) {
        if(sender.state == .on){
            settings.setBoolData(key: "tab", data: true)
        }
        else{
            settings.setBoolData(key: "tab", data: false)
        }
    }
    
    
}
