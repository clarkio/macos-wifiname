//
//  SSID.swift
//  wifiname
//
//  Created by Dhanish on 16/05/2024.
//  Copyright © 2024 Clarkio. All rights reserved.
//

import SwiftUI
import CoreWLAN

extension AppDelegate: CWEventDelegate {
    
    func getSSID() -> String? {
        let wifiInterface = wifiClient.interface()!
        return wifiInterface.ssid()
    }
    
    func listenForSsidChanges() {
        wifiClient.delegate = self
        do {
            try wifiClient.startMonitoringEvent(with: .ssidDidChange)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func ssidDidChangeForWiFiInterface(withName interfaceName: String) {
        DispatchQueue.main.async {
            self.updateStatusBar()
        }
    }
}

