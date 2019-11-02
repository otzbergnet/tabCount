//
//  SafariExtensionViewController.swift
//  tabCount Extension
//
//  Created by Claus Wolf on 02.11.19.
//  Copyright © 2019 Claus Wolf. All rights reserved.
//

import SafariServices

class SafariExtensionViewController: SFSafariExtensionViewController {
    
    static let shared: SafariExtensionViewController = {
        let shared = SafariExtensionViewController()
        shared.preferredContentSize = NSSize(width:320, height:240)
        return shared
    }()

}
