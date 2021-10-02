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
    }
    
    override func popoverViewController() -> SFSafariExtensionViewController {
        return SafariExtensionViewController.shared
    }
    
    
    func getCounts(){
        let autoCloseCount = settings.getIntData(key: "autoCloseCount")
        let shouldAutoClose = settings.getBoolData(key: "autoclose")
        let preventNewCount = settings.getIntData(key: "preventNewCount")
        let preventNew = settings.getBoolData(key: "preventNew")
        let enforceTotalTabCountState = settings.getBoolData(key: "enforceTotalTabCount")

        self.helper.getCounts() { (res) in
            switch res {
            case .success(let counts):
                var tabCount = 0
                self.helper.updateCountBadge(windowCount: counts.windowCount, tabCount: counts.activeWindowTabs, totalTabCount: counts.totalTabs)
                if(!shouldAutoClose && !preventNew){
                    return
                }
                if(enforceTotalTabCountState) {
                    tabCount = counts.totalTabs
                }
                else {
                    tabCount = counts.activeWindowTabs
                }
                
                if(shouldAutoClose && tabCount > (autoCloseCount+1)){
                    self.mayCloseTab = false
                    return
                }
                else if(tabCount == autoCloseCount){
                    self.mayCloseTab = true
                }
                if(preventNew && tabCount > (preventNewCount+1)){
                    self.mayPreventTab = false
                    return
                }
                else if(tabCount == preventNewCount){
                    self.mayPreventTab = true
                }
                if(shouldAutoClose && tabCount > autoCloseCount && self.mayCloseTab){
                    self.actionPreventTabs(first: true)
                }
                else if(preventNew && tabCount > preventNewCount && self.mayPreventTab){
                    self.actionPreventTabs(first: false)
                }
            case .failure(let error):
                print(error)
            }
        }
        
    }
    
    func actionPreventTabs(first: Bool) {
        SFSafariApplication.getActiveWindow { (safariWindow) in
            safariWindow?.getAllTabs(completionHandler: { (tabs) in
                switch first {
                    case true:
                        tabs[0].close()
                    case false:
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


