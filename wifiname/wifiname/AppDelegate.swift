//
//  AppDelegate.swift
//  wifiname
//
//  Created by Brian Clark on 12/27/17.
//  Copyright © 2017 Clarkio. All rights reserved.
//

import Cocoa
import CoreWLAN

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, CWEventDelegate {
    
    let statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let wifiClient = CWWiFiClient.shared()
    var currentSsid: String? = nil
    var visible: Bool = true
    var highlightCheckCount: Int = 0
    var isHighlighted: Bool = false
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        listenForSsidChanges()
        updateStatusBar()
        constructMenu()
    }
    
    func updateStatusBar() {
        if let button = self.statusBarItem.button {
            if let ssid = self.getSSID() {
                currentSsid = ssid
                button.title = ssid
            } else {
                currentSsid = "Disconnected"
                button.title = "Disconnected"
            }
            highlightChange()
        }
    }
    
    func highlightChange() {
        highlightStatusBarItem()
        
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { (OriginalTimer) in
            if self.isHighlighted {
                self.unhighlighStatusBarItem()
            } else {
                self.highlightStatusBarItem()
            }
            
            if self.highlightCheckCount == 6 {
                self.highlightCheckCount = 0
                self.unhighlighStatusBarItem()
                OriginalTimer.invalidate()
            }
        })
    }
    
    func highlightStatusBarItem() {
        if let button = self.statusBarItem.button {
            button.highlight(true)
            self.isHighlighted = true
            self.highlightCheckCount += 1
        }
    }
    
    func unhighlighStatusBarItem() {
        if let button = self.statusBarItem.button {
            button.highlight(false)
            self.isHighlighted = false
        }
    }
    
    func getSSID() -> String? {
        let defaultInterface = wifiClient.interface()!
        return defaultInterface.ssid()
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
    
    func constructMenu() {
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: "Toggle Visibility", action: #selector(AppDelegate.toggleVisibility(_:)), keyEquivalent: "T"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusBarItem.menu = menu
    }
    
    @objc func toggleVisibility(_ sender: Any?) {
        visible = visible ? false : true
        if visible {
            self.updateStatusBar()
        } else {
            if let button = self.statusBarItem.button {
                let hideText = String.init(repeating: "_", count: (self.currentSsid!.count))
                button.title = hideText
            }
        }
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        do {
            try wifiClient.stopMonitoringEvent(with: .ssidDidChange)
        } catch {
            print(error.localizedDescription)
        }
    }
}
