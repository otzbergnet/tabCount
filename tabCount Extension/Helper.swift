//
//  Helper.swift
//  Tab Count
//
//  Created by Claus Wolf on 09.11.19.
//  Copyright © 2019 Claus Wolf. All rights reserved.
//

import Foundation
import SafariServices

class Helper {

    let settings = SettingsHelper()
    
    func updateCountBadge(windowCount: Int, tabCount: Int, totalTabCount: Int){
        let showWindow = settings.getBoolData(key: "window")
        let showTab = settings.getBoolData(key: "tab")
        
        let maxTabs = settings.getIntData(key: "maxTabs")
        let maxWindows = settings.getIntData(key: "maxWindows")
        
        let autoCloseCount = settings.getIntData(key: "autoCloseCount")
        let shouldAutoClose = settings.getBoolData(key: "autoclose")
        
        let preventNewCount = settings.getIntData(key: "preventNewCount")
        let preventNew = settings.getBoolData(key: "preventNew")
        
        let countPerWindow = settings.getBoolData(key: "countPerWindow")
        let enforceTotalTabCount = settings.getBoolData(key: "enforceTotalTabCount")
        
        var badgeText = ""
        
        var evalTabCount = 0
        var evalBlockTabCount = 0
        if (countPerWindow) {
            evalTabCount = tabCount
        }
        else {
            evalTabCount = totalTabCount
        }
        if(enforceTotalTabCount) {
            evalBlockTabCount = totalTabCount
        }
        else {
            evalBlockTabCount = tabCount
        }
        
        if(shouldAutoClose && evalBlockTabCount == autoCloseCount){
            badgeText = "✗"
        }
        else if(preventNew && evalBlockTabCount == preventNewCount){
            badgeText = "✗"
        }
        else if(shouldAutoClose && evalBlockTabCount > autoCloseCount){
            badgeText = "!!"
        }
        else if(preventNew && evalBlockTabCount > preventNewCount){
            badgeText = "!!"
        }
        else if(showTab && evalTabCount >= maxTabs && showWindow && windowCount >= maxWindows){
            //show both tabCount & windowCount
            badgeText = "\(evalTabCount) "
            badgeText += exponent(i: windowCount)
        }
        else if(showTab && evalTabCount >= maxTabs && showWindow && windowCount <= maxWindows){
            //show only TabCount, windowCount condition is not met
            badgeText = "\(evalTabCount)"
        }
        else if(showTab && evalTabCount <= maxTabs && showWindow && windowCount >= maxWindows){
            //show only window count as an exponent - it'll look funny, but it'll be consistent
            //badgeText = "\(tabCount) "
            badgeText = exponent(i: windowCount)
        }
        else if(showTab && evalTabCount >= maxTabs && !showWindow ){
            //the tab count is requested and meets requirement
            badgeText = "\(evalTabCount)"
        }
        else if(!showTab && showWindow && windowCount >= maxWindows){
            //as the tabCount is not requested, we will show the windowCount as the big badge number
            badgeText = "\(windowCount)"
        }
        else{
            //all other cases lead to an empty badge
            badgeText = ""
        }
        SFSafariApplication.getActiveWindow { (window) in
			window?.getToolbarItem { $0?.setBadgeText("999")}
            window?.getToolbarItem { $0?.setBadgeText(badgeText)}
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
    
    func getCounts(completion: @escaping (Result<CountObject, Error>) -> ()){
        let dontCountPinnedTabs = self.settings.getBoolData(key: "dontCountPinnedTabs")
        let counts = CountObject()
        SFSafariApplication.getAllWindows { safariWindows in
            var totalTabs = 0
            counts.windowCount = safariWindows.count
            let compareWindowCount = safariWindows.count
            var windowCountIteration = 0
            for singleSafariWindow in safariWindows{
                singleSafariWindow.getAllTabs{ tabs in
                    windowCountIteration += 1
                    if(dontCountPinnedTabs){
                        // this one needs work, as the completion might fire before all the other completions are done
                        let singleWindowTabCount = tabs.count
                        var singleWindowCompareTabCount = 0
                        for tab in tabs {
                            singleWindowCompareTabCount += 1
                            tab.getContainingWindow { (window) in
                                if(window != nil){
                                    totalTabs = totalTabs + 1
                                }
                                if (windowCountIteration == compareWindowCount && singleWindowTabCount == singleWindowCompareTabCount){
                                    self.getActiveWindowTabCounts { activeWindowCountResult in
                                        switch activeWindowCountResult {
                                        case .success(let resultCount):
                                            counts.totalTabs = totalTabs
                                            counts.windowCount = windowCountIteration
                                            counts.activeWindowTabs = resultCount
                                            completion(.success(counts))
                                        case .failure(let error):
                                            print(error)
                                            counts.activeWindowTabs = 0
                                            completion(.success(counts))
                                        }
                                    }
                                }
                            }
                        }
                    }
                    else {
                        totalTabs = totalTabs + tabs.count
                        counts.totalTabs = totalTabs
                        if (windowCountIteration == counts.windowCount){
                            self.getActiveWindowTabCounts { activeWindowCountResult in
                                switch activeWindowCountResult {
                                case .success(let resultCount):
                                    counts.activeWindowTabs = resultCount
                                    completion(.success(counts))
                                case .failure(let error):
                                    print(error)
                                    counts.activeWindowTabs = 0
                                    completion(.success(counts))
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getActiveWindowTabCounts(completion: @escaping (Result<Int, Error>) -> ()){
        let dontCountPinnedTabs = self.settings.getBoolData(key: "dontCountPinnedTabs")
        SFSafariApplication.getActiveWindow { (safariWindow) in
            safariWindow?.getAllTabs(completionHandler: { (tabs) in
                if(dontCountPinnedTabs){
                    var activeWindowTabCount = 0
                    let tmpTabCount = tabs.count
                    var tmpTabCountCompare = 0
                    for tab in tabs {
                        tmpTabCountCompare += 1
                        tab.getContainingWindow { (window) in
                            if(window != nil){
                                activeWindowTabCount = activeWindowTabCount + 1
                                if(tmpTabCount == tmpTabCountCompare){
                                    completion(.success(activeWindowTabCount))
                                }
                            }
                        }
                    }
                }
                else{
                    completion(.success(tabs.count))
                }
            })
        }
    }
    
}


class CountObject{
    var windowCount = 0
    var totalTabs = 0
    var activeWindowTabs = 0
}
