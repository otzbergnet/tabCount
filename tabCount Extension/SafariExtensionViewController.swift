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
    
    @IBOutlet weak var badgeFromBox: NSTextField!
    @IBOutlet weak var badgeFromSlider: NSSlider!
    
    @IBOutlet weak var windowCountCheckBox: NSButton!
    
    
    static let shared: SafariExtensionViewController = {
        let shared = SafariExtensionViewController()
        shared.preferredContentSize = NSSize(width:320, height:345)
        return shared
    }()
    
    func popoverViewController() -> SafariExtensionViewController {
        return SafariExtensionViewController.shared
    }
    
    override func viewDidLoad() {
        getPreviousMaxTabs()
        getShowWindowState()
        updateDataLabels()
    }
    
    override func viewWillAppear() {
        getPreviousMaxTabs()
        getShowWindowState()
        updateDataLabels()
    }
    
    override func viewWillDisappear() {
        let maxTabsFromSlider = badgeFromSlider.integerValue
        if let maxTabsFromBox = Int(badgeFromBox.stringValue){
            settings.setIntData(key: "maxTabs", data: maxTabsFromBox)
        }
        else{
            settings.setIntData(key: "maxTabs", data: maxTabsFromSlider)
        }
    }
    
    func closeTabsToLeft(){

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

    
    func getPreviousMaxTabs(){
        let maxTabs = settings.getIntData(key: "maxTabs")
        
        if(maxTabs > 0){
            badgeFromBox.stringValue = "\(maxTabs)"
            badgeFromSlider.integerValue = maxTabs
        }
        else{
            badgeFromBox.stringValue = "10"
            settings.setIntData(key: "maxTabs", data: 10)
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
    
    
    @IBAction func badgeFromSlider(_ sender: Any) {
        
        let maxTabs = badgeFromSlider.integerValue
        badgeFromBox.stringValue = "\(maxTabs)"
        settings.setIntData(key: "maxTabs", data: maxTabs)
        
    }

    @IBAction func badgeFromBoxAction(_ sender: NSTextField) {
        if let maxTabsFromBox = Int(badgeFromBox.stringValue){
            if(maxTabsFromBox > 0 && maxTabsFromBox < 100){
                badgeFromSlider.integerValue = maxTabsFromBox
                settings.setIntData(key: "maxTabs", data: maxTabsFromBox)
            }
            else{
                badgeFromSlider.integerValue = 10
                badgeFromBox.stringValue = "10"
                settings.setIntData(key: "maxTabs", data: 10)
            }
            
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
    }
    
    
}
