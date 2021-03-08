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
    
    var mayCloseTab = true
    var mayPreventTab = true
    
    let settings = SettingsHelper()
    let helper = Helper()
    
    
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
        getCurrentWindowCount()
    }
    
    override func popoverViewController() -> SFSafariExtensionViewController {
        return SafariExtensionViewController.shared
    }
    
    
    func getCounts(){
        SFSafariApplication.getAllWindows { (safariWindows) in
            self.windowCount = safariWindows.count
            var newTabCount = 0;
            for singleSafariWindow in safariWindows{
                singleSafariWindow.getAllTabs{ tabs in
                    newTabCount = newTabCount + tabs.count
                    self.helper.updateCountBadge(windowCount: self.windowCount, tabCount: newTabCount)
                }
            }
            self.tabCount = newTabCount;
        }
    }
    
    func getCurrentWindowCount(){
        print("getCurrentWindowCount")
        let autoCloseCount = settings.getIntData(key: "autoCloseCount")
        let shouldAutoClose = settings.getBoolData(key: "autoclose")
        let preventNewCount = settings.getIntData(key: "preventNewCount")
        let preventNew = settings.getBoolData(key: "preventNew")

        if(!shouldAutoClose && !preventNew){
            return
        }
        SFSafariApplication.getActiveWindow { (safariWindow) in
            safariWindow?.getAllTabs(completionHandler: { (tabs) in

                let count = tabs.count
                if(shouldAutoClose && count > (autoCloseCount+1)){
                    self.mayCloseTab = false
                    return
                }
                else if(count == autoCloseCount){
                    self.mayCloseTab = true
                }
                if(preventNew && count > (preventNewCount+1)){
                    self.mayPreventTab = false
                    return
                }
                else if(count == preventNewCount){
                    self.mayPreventTab = true
                }
                if(shouldAutoClose && count > autoCloseCount && self.mayCloseTab){
                    tabs[0].close()
                }
                else if(preventNew && count > preventNewCount && self.mayPreventTab){
                    tabs.last?.close()
                }
            })
        }
    }
    
    
    func updateBadge(text: String){
        SFSafariApplication.getActiveWindow { (window) in
            window?.getToolbarItem { $0?.setBadgeText(text)}
        }
    }
    
}
