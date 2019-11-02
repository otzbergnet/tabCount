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
    
    
    
    static let shared: SafariExtensionViewController = {
        let shared = SafariExtensionViewController()
        shared.preferredContentSize = NSSize(width:320, height:240)
        return shared
    }()
    
    func popoverViewController() -> SafariExtensionViewController {
        return SafariExtensionViewController.shared
    }
    
    override func viewDidLoad() {
        getPreviousMaxTabs()
        updateDataLabels()
    }
    
    override func viewWillAppear() {
        getPreviousMaxTabs()
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
            badgeFromSlider.integerValue = maxTabsFromBox
            settings.setIntData(key: "maxTabs", data: maxTabsFromBox)
        }
    }
        
}
