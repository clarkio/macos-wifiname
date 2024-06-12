//
//  Authorization.swift
//  wifiname
//
//  Created by Dhanish on 16/05/2024.
//  Copyright © 2024 Clarkio. All rights reserved.
//

import SwiftUI
import CoreLocation

extension AppDelegate: CLLocationManagerDelegate {
    
    func checkAuthorizationStatus() {
        let currentStatus = locationManager.authorizationStatus
        switch currentStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                listenForSsidChanges()
                updateStatusBar()
                constructMenu()
            case .denied, .restricted:
                prompt.toEnableLocationServices()
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            @unknown default:
                break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkAuthorizationStatus()
    }
}
