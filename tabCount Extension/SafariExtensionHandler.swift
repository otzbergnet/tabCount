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
        let countPerWindow = settings.getBoolData(key: "countPerWindow")
        
        if (!countPerWindow){
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
        else{
            self.windowCount = 0;
            SFSafariApplication.getAllWindows { (safariWindows) in
                self.windowCount = safariWindows.count
            }
            SFSafariApplication.getActiveWindow { (safariWindow) in
                var newTabCount = 0;
                if let window = safariWindow {
                    window.getAllTabs{ tabs in
                        newTabCount = newTabCount + tabs.count
                        self.helper.updateCountBadge(windowCount: self.windowCount, tabCount: newTabCount)
                    }
                    self.tabCount = newTabCount;
                }
                
            }
        }
        
        
    }
    
    func getCurrentWindowCount(){
//        print("getCurrentWindowCount")
        let autoCloseCount = settings.getIntData(key: "autoCloseCount")
        let shouldAutoClose = settings.getBoolData(key: "autoclose")
        let preventNewCount = settings.getIntData(key: "preventNewCount")
        let preventNew = settings.getBoolData(key: "preventNew")
        let enforceTotalTabCountState = settings.getBoolData(key: "enforceTotalTabCount")

        if(!shouldAutoClose && !preventNew){
            return
        }
        getCounts(enforceTotalTabCountState: enforceTotalTabCountState) { (res) in
            switch res {
            case .success(let counts):
                if(shouldAutoClose && counts.tabs > (autoCloseCount+1)){
                    self.mayCloseTab = false
                    return
                }
                else if(counts.tabs == autoCloseCount){
                    self.mayCloseTab = true
                }
                if(preventNew && counts.tabs > (preventNewCount+1)){
                    self.mayPreventTab = false
                    return
                }
                else if(counts.tabs == preventNewCount){
                    self.mayPreventTab = true
                }
                if(shouldAutoClose && counts.tabs > autoCloseCount && self.mayCloseTab){
                    self.actionPreventTabs(first: true)
                }
                else if(preventNew && counts.tabs > preventNewCount && self.mayPreventTab){
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
    
    
    func getCounts(enforceTotalTabCountState : Bool, completion: @escaping (Result<CountObject, Error>) -> ()){
        let counts = CountObject()
        if(enforceTotalTabCountState){
            SFSafariApplication.getAllWindows { safariWindows in
                var count = 0;
                let windowCount = safariWindows.count
                var windowCountIteration = 0
                for singleSafariWindow in safariWindows{
                    singleSafariWindow.getAllTabs{ tabs in
                        windowCountIteration += 1
//                        print("windowCount: \(windowCount)")
//                        print("windowCountIteration: \(windowCountIteration)")
                        count = count + tabs.count
                        counts.tabs = count
                        if (windowCountIteration == windowCount){
                            completion(.success(counts))
                        }
                    }
                }
            }
        }
        else{
            SFSafariApplication.getActiveWindow { (safariWindow) in
                safariWindow?.getAllTabs(completionHandler: { (tabs) in
                    counts.tabs = tabs.count
                    completion(.success(counts))
                })
            }
        }
    }
    
    
    func updateBadge(text: String){
        SFSafariApplication.getActiveWindow { (window) in
            window?.getToolbarItem { $0?.setBadgeText(text)}
        }
    }
    
}

class CountObject{
    var windows = 0
    var tabs = 0
}
