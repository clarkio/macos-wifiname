//
 //  Menu.swift
 //  wifiname
 //
 //  Created by Dhanish on 16/05/2024.
 //  Copyright © 2024 Clarkio. All rights reserved.
 //

 import SwiftUI

 extension AppDelegate {

     func constructMenu() {
         let menu = NSMenu()

         menu.addItem(NSMenuItem(title: visible ? "Hide" : "Show", action: #selector(toggleVisibility(_:)), keyEquivalent: "t"))
         menu.addItem(NSMenuItem(title: "About", action: #selector(about), keyEquivalent: ","))
         menu.addItem(NSMenuItem.separator())
         menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

         statusBarItem.menu = menu
     }

     @objc func about(sender: NSMenuItem) {
         NSApp.orderFrontStandardAboutPanel()
         NSApp.activate(ignoringOtherApps: true)
     }
 }
