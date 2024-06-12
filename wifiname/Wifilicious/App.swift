//
//  App.swift
//  wifiname
//
//  Created by Brian Clark on 12/27/17.
//  Copyright © 2024 Clarkio. All rights reserved.
//  www.clarkio.com

import SwiftUI
import CoreWLAN
import CoreLocation

@main
struct Wifiname: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    
    static private (set) var instance: AppDelegate?
    
    lazy var statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let locationManager = CLLocationManager()
    let wifiClient = CWWiFiClient.shared()
    var visible = true
    
    let prompt = Prompt()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        locationManager.delegate = self
        AppDelegate.instance = self
        checkAuthorizationStatus()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        do {
            try wifiClient.stopMonitoringEvent(with: .ssidDidChange)
        } catch {
            print(error.localizedDescription)
        }
    }
}
