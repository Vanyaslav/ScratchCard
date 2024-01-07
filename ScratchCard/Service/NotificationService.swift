//
//  NotificationService.swift
//  ScratchCard
//
//  Created by Tomas Baculák on 05/06/2023.
//

import Foundation
import CombineExt
import UserNotifications
import Combine

protocol NotificationProtocol {
    var register: PassthroughRelay<UNUserNotificationCenterDelegate> { get }
    var showAlert: PassthroughRelay<String> { get }
}

class NotificationService: NotificationProtocol {
    private var cancellables = Set<AnyCancellable>()
    
    let register = PassthroughRelay<UNUserNotificationCenterDelegate>()
    let showAlert = PassthroughRelay<String>()
    
    init() {
        register
            .sink(receiveValue: UNUserNotificationCenter.requestAndDelegate)
            .store(in: &cancellables)
        
        showAlert
            .map { UNUserNotificationCenter.sendNotification(subTitle: $0) }
            .sink { _ in  }
            .store(in: &cancellables)
    }
}
