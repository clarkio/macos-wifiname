//
 //  Visibility.swift
 //  wifiname
 //
 //  Created by Dhanish on 16/05/2024.
 //  Copyright © 2024 Clarkio. All rights reserved.
 //

 import SwiftUI

 extension AppDelegate {

     @objc func toggleVisibility(_ sender: Any?) {
         visible.toggle()
         updateStatusBar()
         constructMenu()
     }

     func updateStatusBar() {
         guard let button = statusBarItem.button else { return }
         if let ssid = getSSID(), !ssid.isEmpty && visible {
             button.title = ssid
             if let connectedImage = NSImage(named: NSImage.Name("connected")) {
                 let newSize = NSSize(width: 20, height: 20)
                 connectedImage.size = newSize
                 button.image = connectedImage
             }
         } else {
             button.title = visible ? "Disconnected" : "🙈"
             if let disconnectedImage = NSImage(named: NSImage.Name("disconnected")) {
                 let newSize = NSSize(width: 20, height: 20)
                 disconnectedImage.size = newSize
                 button.image = visible ? disconnectedImage : nil
             }
         }
     }

 }
