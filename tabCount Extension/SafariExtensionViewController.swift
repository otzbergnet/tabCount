//
//  SafariExtensionViewController.swift
//  tabCount Extension
//
//  Created by Claus Wolf on 30.10.19.
//  Copyright © 2019 Claus Wolf. All rights reserved.
//

import SafariServices

class SafariExtensionViewController: SFSafariExtensionViewController, NSTextFieldDelegate {
    
    var settings = SettingsHelper()
    var tabCount = 0
    var windowCount = 0
    
    @IBOutlet weak var windowCountLabel: NSTextField!
    @IBOutlet weak var tabCountLabel: NSTextField!
    
    @IBOutlet weak var tabCountBox: NSComboBox!
    @IBOutlet weak var windowCountBox: NSComboBox!
    
    @IBOutlet weak var tabCountCheckBox: NSButton!
    @IBOutlet weak var windowCountCheckBox: NSButton!
    
    let helper = Helper()
    
    static let shared: SafariExtensionViewController = {
        let shared = SafariExtensionViewController()
        shared.preferredContentSize = NSSize(width:280, height:240)
        return shared
    }()
    
    func popoverViewController() -> SafariExtensionViewController {
        return SafariExtensionViewController.shared
    }
    
    override func viewDidLoad() {
        populateComboBoxes()
        getPreviousMaxTabs()
        getPreviousMaxWindows()
        getShowTabState()
        getShowWindowState()
        updateDataLabels()
    }
    
    override func viewWillAppear() {
        getPreviousMaxTabs()
        getPreviousMaxWindows()
        getShowTabState()
        getShowWindowState()
        updateDataLabels()
    }
    
    override func viewWillDisappear() {
        
    }
    
    override func viewDidDisappear() {
        
    }
    
    func closeTabsToLeft(){
        SafariExtensionViewController.shared.dismissPopover()
        SFSafariApplication.getActiveWindow { (window) in
            guard let window = window else {
                return
            }
            window.getActiveTab { (activeTab) in
                window.getAllTabs { (tabs) in
                    
                    let tabIndex: Int = tabs.firstIndex(where: { activeTab!.isEqual($0) })!
                    for n in 0...(tabIndex-1){
                        tabs[n].close()
                    }
                    
                }
            }
        }
    }
    
    func closeTabsToRight(){
        SafariExtensionViewController.shared.dismissPopover()
        SFSafariApplication.getActiveWindow { (window) in
            guard let window = window else {
                return
            }
            window.getActiveTab { (activeTab) in
                window.getAllTabs { (tabs) in
                    
                    let tabIndex: Int = tabs.firstIndex(where: { activeTab!.isEqual($0) })!
                    for n in (tabIndex+1)...tabs.count{
                        tabs[n].close()
                    }
                    
                }
            }
        }
    }
    
    func populateComboBoxes(){
        for i in 1...100{
            tabCountBox.addItem(withObjectValue: i)
        }
        for n in 1...25{
            windowCountBox.addItem(withObjectValue: n)
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
            windowCountCheckBox.state = .on
        }
        else{
            windowCountCheckBox.state = .off
        }
    }
    
    func getShowTabState(){
        let tabState = settings.getBoolData(key: "tab")
        if(tabState){
            tabCountCheckBox.state = .on
        }
        else{
            tabCountCheckBox.state = .off
        }
    }
    
    func updateDataLabels(){
        tabCount = 0
        windowCount = 0
        SFSafariApplication.getAllWindows { (safariWindows) in
            self.windowCount = safariWindows.count
            for singleSafariWindow in safariWindows{
                singleSafariWindow.getAllTabs{ tabs in
                    self.tabCount = self.tabCount + tabs.count
                    DispatchQueue.main.async {
                        self.tabCountLabel.stringValue = "\(self.tabCount)"
                        self.windowCountLabel.stringValue = "\(self.windowCount)"
                    }
                }
            }
        }
    }
    
    func resetPopover(){
        tabCountLabel.stringValue = ""
        windowCountLabel.stringValue = ""
    }
    
    @IBAction func tabThresholdBox(_ sender: NSComboBox) {
        if let maxTabsFromBox = Int(tabCountBox.stringValue){
            if(maxTabsFromBox > 0 && maxTabsFromBox <= 100){
                settings.setIntData(key: "maxTabs", data: maxTabsFromBox)
            }
            else{
                tabCountBox.stringValue = "10"
                settings.setIntData(key: "maxTabs", data: 10)
            }
            helper.updateCountBadge(windowCount: self.windowCount, tabCount: self.tabCount)
        }
    }
    
    @IBAction func windowThresholdBox(_ sender: Any) {
        if let maxWindowsFromBox = Int(windowCountBox.stringValue){
            if(maxWindowsFromBox > 0 && maxWindowsFromBox <= 100){
                settings.setIntData(key: "maxWindows", data: maxWindowsFromBox)
            }
            else{
                windowCountBox.stringValue = "3"
                settings.setIntData(key: "maxWindows", data: 3)
            }
            helper.updateCountBadge(windowCount: self.windowCount, tabCount: self.tabCount)
        }
    }
    
    @IBAction func closeToLeftAction(_ sender: Any) {
        closeTabsToLeft()
    }
    
    @IBAction func closeToRightAction(_ sender: Any) {
        closeTabsToRight()
    }
    
    @IBAction func windowCountCheckBoxChanged(_ sender: NSButton) {
        if(sender.state == .on){
            settings.setBoolData(key: "window", data: true)
        }
        else{
            settings.setBoolData(key: "window", data: false)
        }
        helper.updateCountBadge(windowCount: self.windowCount, tabCount: self.tabCount)
    }
    
    @IBAction func tabCountCheckBoxChanged(_ sender: NSButton) {
        if(sender.state == .on){
            settings.setBoolData(key: "tab", data: true)
        }
        else{
            settings.setBoolData(key: "tab", data: false)
        }
        helper.updateCountBadge(windowCount: self.windowCount, tabCount: self.tabCount)
    }
    
    
    
}
