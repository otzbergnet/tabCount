//
//  SettingsViewController.swift
//  Tab Count
//
//  Created by Claus Wolf on 10.11.19.
//  Copyright © 2019 Claus Wolf. All rights reserved.
//

import Cocoa
import SafariServices

class SettingsViewController: NSView {
 
    let settings = SettingsHelper()
    
    @IBOutlet weak var tabCountBox: NSTextField!
    @IBOutlet weak var windowCountBox: NSTextField!
    
    @IBOutlet weak var windowCountCheck: NSButton!
    @IBOutlet weak var tabCountCheck: NSButton!
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
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
    
    func saveTabCountHelper(){
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
    
    func saveWindowCountHelper(){
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
    

    @IBAction func saveAll(_ sender: Any) {
        saveWindowCountHelper()
        saveTabCountHelper()
        
    }
    
    @IBAction func windowCountSave(_ sender: Any) {
        saveWindowCountHelper()
    }
    
    @IBAction func tabCountSave(_ sender: Any) {
        saveTabCountHelper()
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
