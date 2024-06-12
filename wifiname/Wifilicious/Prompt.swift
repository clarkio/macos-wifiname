//
//  Prompt.swift
//  wifiname
//
//  Created by Dhanish on 16/05/2024.
//  Copyright © 2024 Clarkio. All rights reserved.
//

import SwiftUI

class Prompt {
    var isPromptingLocationServices = false

    func toEnableLocationServices() {
        
        guard !isPromptingLocationServices else { return }
        isPromptingLocationServices = true
        
        let alert = NSAlert()
        alert.alertStyle = .critical
        alert.messageText = "Location Services Disabled"
        alert.informativeText = "To continue, please enable Location Services in your privacy settings. This is necessary to access the Wi-Fi network information required for the app to function"
        alert.addButton(withTitle: "Open System Preferences")
        alert.addButton(withTitle: "Cancel")
        
        if alert.runModal() == .alertFirstButtonReturn,
           let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_LocationServices") {
            NSWorkspace.shared.open(url)
        }
        
        isPromptingLocationServices = false
    }
}
