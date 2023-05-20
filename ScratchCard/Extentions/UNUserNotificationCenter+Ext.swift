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
        Self.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                debugPrint("Local notifications granted!")
            } else if let error = error {
                debugPrint(error.localizedDescription)
            }
        }
        
        Self.current().delegate = object
    }
    
    static func sendNotification(
        title: String = "Activation failed!",
        subTitle: String,
        interval: TimeInterval = 1
    ) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = title
        content.sound = UNNotificationSound.defaultCritical
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        Self.current().add(request)
    }
}
