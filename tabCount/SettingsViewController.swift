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
    @IBOutlet weak var autoCloseCountBox: NSTextField!
    @IBOutlet weak var preventNewCountBox: NSTextField!
    
    @IBOutlet weak var windowCountCheck: NSButton!
    @IBOutlet weak var tabCountCheck: NSButton!
    @IBOutlet weak var keepPinnedTabsCheck: NSButton!
    @IBOutlet weak var countPerWindowCheck: NSButton!
    
    
    
    @IBOutlet weak var autoCloseCheck: NSButtonCell!
    @IBOutlet weak var preventNewCheck: NSButton!
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        initialSetup()
        getPreviousMaxTabs()
        getPreviousMaxWindows()
        getPreviousMaxAutoClose()
        getPreviousMaxPreventNew()
        getShowWindowState()
        getShowTabState()
        getAutoCloseState()
        getPreventNewState()
        getPinnedTabState()
        getCountPerWindowState()
    }

    
    func initialSetup(){
        let previousSetup = settings.getBoolData(key: "setup")
        if(!previousSetup){
            settings.setBoolData(key: "tab", data: true)
            settings.setBoolData(key: "window", data: false)
            settings.setBoolData(key: "autoclose", data: false)
            settings.setBoolData(key: "preventNew", data: false)
            settings.setBoolData(key: "setup", data: true)
            settings.setBoolData(key: "countPerWindow", data: false)
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
    
    func getPreviousMaxAutoClose(){
        let maxAutoClose = settings.getIntData(key: "autoCloseCount")
        if(maxAutoClose > 0){
            autoCloseCountBox.stringValue = "\(maxAutoClose)"
        }
        else{
            autoCloseCountBox.stringValue = "30"
            settings.setIntData(key: "autoCloseCount", data: 30)
        }
    }

    func getPreviousMaxPreventNew(){
        let maxPreventNew = settings.getIntData(key: "preventNewCount")
        if(maxPreventNew > 0){
            preventNewCountBox.stringValue = "\(maxPreventNew)"
        }
        else{
            preventNewCountBox.stringValue = "30"
            settings.setIntData(key: "preventNewCount", data: 30)
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
    
    func getAutoCloseState(){
        let autoCloseState = settings.getBoolData(key: "autoclose")
        if(autoCloseState){
            autoCloseCheck.state = .on
        }
        else{
            autoCloseCheck.state = .off
        }
    }

    func getPreventNewState(){
        let preventNewState = settings.getBoolData(key: "preventNew")
        if(preventNewState){
            preventNewCheck.state = .on
        }
        else{
            preventNewCheck.state = .off
        }
    }
    
    func getPinnedTabState(){
        let pinnedTabState = settings.getBoolData(key: "pinnedTab")
        if(pinnedTabState){
            keepPinnedTabsCheck.state = .on
        }
        else{
            keepPinnedTabsCheck.state = .off
        }
    }
    
    func getCountPerWindowState(){
        let countPerWindowState = settings.getBoolData(key: "countPerWindow")
        if(countPerWindowState){
            countPerWindowCheck.state = .on
        }
        else{
            countPerWindowCheck.state = .off
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
    
    func saveAutoCloseCountHelper(){
        if let autoCloseFromBox = Int(autoCloseCountBox.stringValue){
            if(autoCloseFromBox > 0){
               settings.setIntData(key: "autoCloseCount", data: autoCloseFromBox)
            }
            else if(autoCloseCheck.state == .on){
                autoCloseCountBox.stringValue = "30"
                settings.setIntData(key: "autoCloseCount", data: 30)
            }
        }
        else{
            if(autoCloseCheck.state == .on){
                autoCloseCountBox.stringValue = "30"
                settings.setIntData(key: "autoCloseCount", data: 30)
            }
        }
    }
    
    func savePreventNewHelper(){
        if let preventNewFromBox = Int(preventNewCountBox.stringValue){
            if(preventNewFromBox > 0){
               settings.setIntData(key: "preventNewCount", data: preventNewFromBox)
            }
            else if(preventNewCheck.state == .on){
                preventNewCountBox.stringValue = "30"
                settings.setIntData(key: "preventNewCount", data: 30)
            }
        }
        else{
            if(preventNewCheck.state == .on){
                preventNewCountBox.stringValue = "30"
                settings.setIntData(key: "preventNewCount", data: 30)
            }
        }
    }
    

    @IBAction func saveAll(_ sender: Any) {
        saveWindowCountHelper()
        saveTabCountHelper()
        saveAutoCloseCountHelper()
        savePreventNewHelper()
    }
    
    @IBAction func windowCountSave(_ sender: Any) {
        saveWindowCountHelper()
    }
    
    @IBAction func tabCountSave(_ sender: Any) {
        saveTabCountHelper()
    }
       
    @IBAction func autoCloseSave(_ sender: Any) {
        saveAutoCloseCountHelper()
    }
    
    @IBAction func prveventNewSave(_ sender: Any) {
        savePreventNewHelper()
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
    
    @IBAction func saveAutoClose(_ sender: NSButton) {
        if(sender.state == .on){
            settings.setBoolData(key: "autoclose", data: true)
            settings.setBoolData(key: "preventNew", data: false)
            self.preventNewCheck.state = .off
            saveAutoCloseCountHelper()
        }
        else{
            settings.setBoolData(key: "autoclose", data: false)
        }
    }
    
    @IBAction func savePreventNew(_ sender: NSButton) {
        if(sender.state == .on){
            settings.setBoolData(key: "preventNew", data: true)
            settings.setBoolData(key: "autoclose", data: false)
            self.autoCloseCheck.state = .off
            savePreventNewHelper()
        }
        else{
            settings.setBoolData(key: "preventNew", data: false)
        }
    }

    @IBAction func saveKeepPinnedTab(_ sender: NSButton) {
        if(sender.state == .on){
            settings.setBoolData(key: "pinnedTab", data: true)
        }
        else{
            settings.setBoolData(key: "pinnedTab", data: false)
        }
    }
    
    @IBAction func saveCountPerWindowTab(_ sender: NSButton) {
        if(sender.state == .on){
            settings.setBoolData(key: "countPerWindow", data: true)
        }
        else{
            settings.setBoolData(key: "countPerWindow", data: false)
        }
    }
    
    
}
