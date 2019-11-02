//
//  SettingsHelper.swift
//  tab-count
//
//  Created by Claus Wolf on 01.11.19.
//  Copyright © 2019 Claus Wolf. All rights reserved.
//

import Foundation

class SettingsHelper {

    var defaults: UserDefaults

    init(){
        self.defaults = UserDefaults(suiteName: "group.net.otzberg.tabcount")!
    }
    
    func getIntData(key : String) -> Int{
        let data : Int = self.defaults.integer(forKey: key)
        return data
    }
    
    func setIntData(key : String, data: Int){
        self.defaults.set(data, forKey: key)
        self.defaults.synchronize()
    }

    
}
