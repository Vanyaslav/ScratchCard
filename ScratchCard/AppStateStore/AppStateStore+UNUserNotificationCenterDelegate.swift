//
//  AppStateStore+UNUserNotificationCenterDelegate.swift
//  ScratchCard
//
//  Created by Tomas Baculák on 09/05/2023.
//

import Foundation
import UserNotifications

extension AppStateStore: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse) async {
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        [.banner, .badge, .sound]
    }
}
