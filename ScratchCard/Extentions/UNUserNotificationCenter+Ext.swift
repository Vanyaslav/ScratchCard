//
//  UNUserNotificationCenter+Ext.swift
//  ScratchCard
//
//  Created by Tomas Baculák on 09/05/2023.
//

import Foundation
import UserNotifications

extension UNUserNotificationCenter {
    static func requestAndDelegate(object: UNUserNotificationCenterDelegate) {
        UNUserNotificationCenter
            .current()
            .requestAuthorization(options: [.alert, .badge, .sound])
        { success, error in
            if success {
                debugPrint("Local notifications granted!")
            } else if let error = error {
                debugPrint(error.localizedDescription)
            }
        }
        
        UNUserNotificationCenter
            .current().delegate = object
    }
    
    static func sendNotification(title: String, interval: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = "Activation failed!"
        content.subtitle = title
        content.sound = UNNotificationSound.defaultCritical
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        Self.current().add(request)
    }
}
