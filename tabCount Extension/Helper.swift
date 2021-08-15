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
        let counts = CountObject()
        SFSafariApplication.getAllWindows { safariWindows in
            var totalTabs = 0
            counts.windowCount = safariWindows.count
            var windowCountIteration = 0
            for singleSafariWindow in safariWindows{
                singleSafariWindow.getAllTabs{ tabs in
                    windowCountIteration += 1
                    totalTabs = totalTabs + tabs.count
                    counts.totalTabs = totalTabs
                    if (windowCountIteration == counts.windowCount){
                        SFSafariApplication.getActiveWindow { (safariWindow) in
                            safariWindow?.getAllTabs(completionHandler: { (tabs) in
                                counts.activeWindowTabs = tabs.count
                                completion(.success(counts))
                            })
                        }
                    }
                }
            }
        }
    }
    
}


class CountObject{
    var windowCount = 0
    var totalTabs = 0
    var activeWindowTabs = 0
}
