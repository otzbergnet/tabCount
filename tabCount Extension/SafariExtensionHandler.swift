//
//  SafariExtensionHandler.swift
//  tabCount Extension
//
//  Created by Claus Wolf on 30.10.19.
//  Copyright © 2019 Claus Wolf. All rights reserved.
//

import SafariServices

class SafariExtensionHandler: SFSafariExtensionHandler {
    
    var tabCount : Int = 0
    var windowCount : Int = 0
    
    let settings = SettingsHelper()
    
    
    override func messageReceived(withName messageName: String, from page: SFSafariPage, userInfo: [String : Any]?) {
        // This method will be called when a content script provided by your extension calls safari.extension.dispatchMessage("message").
        page.getPropertiesWithCompletionHandler { properties in
            NSLog("The extension received a message (\(messageName)) from a script injected into (\(String(describing: properties?.url))) with userInfo (\(userInfo ?? [:]))")
        }
    }
    
    override func toolbarItemClicked(in window: SFSafariWindow) {
        // This method will be called when your toolbar item is clicked.
    }
    
    
    
    override func validateToolbarItem(in window: SFSafariWindow, validationHandler: @escaping ((Bool, String) -> Void)) {
        // This is called when Safari's state changed in some way that would require the extension's toolbar item to be validated again.
        validationHandler(true, "")
        getCounts()
    }
    
    override func popoverViewController() -> SFSafariExtensionViewController {
        return SafariExtensionViewController.shared
    }
    
    
    func getCounts(){
        SFSafariApplication.getAllWindows { (safariWindows) in
            self.windowCount = safariWindows.count
            for singleSafariWindow in safariWindows{
                singleSafariWindow.getAllTabs{ tabs in
                    self.tabCount = self.tabCount + tabs.count
                    self.updateCountBadge()
                }
            }
        }
    }
    
    func updateCountBadge(){
        let showWindow = settings.getBoolData(key: "window")
        NSLog("TabCount: showWindow: \(showWindow)")
        let showTab = settings.getBoolData(key: "tab")
        NSLog("TabCount: showTab: \(showTab)")
        
        let maxTabs = settings.getIntData(key: "maxTabs")
        NSLog("TabCount: maxTabs: \(maxTabs)")
        let maxWindows = settings.getIntData(key: "maxWindows")
        NSLog("TabCount: maxWindow: \(maxWindows)")
        
        NSLog("TabCount: windowCount: \(self.windowCount)")
        NSLog("TabCount: tabCount: \(self.tabCount)")
        
        var badgeText = ""
        
        
        if(showTab && self.tabCount >= maxTabs && showWindow && self.windowCount >= maxWindows){
            //show both tabCount & windowCount
            badgeText = "\(self.tabCount) "
            badgeText += exponent(i: self.windowCount)
        }
        else if(showTab && self.tabCount >= maxTabs && showWindow && self.windowCount <= maxWindows){
            //show only TabCount, windowCount condition is not met
            badgeText = "\(self.tabCount)"
        }
        else if(showTab && self.tabCount <= maxTabs && showWindow && self.windowCount >= maxWindows){
            //show both tabCount & windowCount, even though the maxTabs was not met
            badgeText = "\(self.tabCount) "
            badgeText += exponent(i: self.windowCount)
        }
        else if(showTab && self.tabCount >= maxTabs && !showWindow ){
            //the tab count is requested and meets requirement
            badgeText = "\(self.tabCount)"
        }
        else if(!showTab && showWindow && self.windowCount >= maxWindows){
            //as the tabCount is not requested, we will show the windowCount as the big badge number
            badgeText = "\(self.windowCount)"
        }
        else{
            //all other cases lead to an empty badge
            badgeText = ""
        }
        
        SFSafariApplication.getActiveWindow { (window) in
            window?.getToolbarItem { $0?.setBadgeText(badgeText)}
        }
        
    }
    
    
    func updateBadge(text: String){
        SFSafariApplication.getActiveWindow { (window) in
            window?.getToolbarItem { $0?.setBadgeText(text)}
        }
    }
    
    func exponent(i: Int) -> String {
        let powers : [String] = [
            "\u{2070}",
            "\u{00B9}",
            "\u{00B2}",
            "\u{00B3}",
            "\u{2074}",
            "\u{2075}",
            "\u{2076}",
            "\u{2077}",
            "\u{2078}",
            "\u{2079}"
        ]
        
        let digits = Array(String(i))
        var string = ""
        
        for d in digits {
            string.append("\(powers[Int(String(d))!])")
        }
        return string
    }
    
}
