//
//  AppStateStore.swift
//  ScratchCard
//
//  Created by Tomas Baculák on 06/05/2023.
//

import Foundation
import Combine
import CombineExt
import UserNotifications

enum State: String {
    case unscratched, scratched, activated
    
    var title: String {
        switch self {
        case .unscratched:
            return "Unscratched"
            
        case .scratched:
            return "Scratched"
            
        case .activated:
            return "Activated"
        }
    }
    
    static var initial: Self {
        .unscratched
    }
}

extension AppStateStore: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        [.banner, .badge, .sound]
    }
}

final class AppStateStore: NSObject, ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    // in
    let shouldGenerateCode = PassthroughSubject<Void, Never>()
    let cancelGenerateCode = PassthroughSubject<Void, Never>()
    let subscribeGenerateCode = PassthroughSubject<Void, Never>()
    let shouldActivate = PassthroughSubject<Void, Never>()
    // out
    @Published private(set) var stateTitle: String
    @Published private(set) var showError: String?
    @Published private(set) var isActivationEnabled: Bool = false
    @Published private(set) var isScratchEnabled: Bool = true
    
    @Published private(set) var generatedCode: String?
    
    private var generateCodeAction: Cancellable?
    
    init(
        stateTitle: String = State.initial.title,
        service: DataServiceProtocol,
        initialCode: String? = nil
    ) {
        self.stateTitle = stateTitle
        self.generatedCode = initialCode
        super.init()
        
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
            .current().delegate = self
        
        let result = shouldActivate
            .withLatestFrom($generatedCode)
            .compactMap { $0 }
            .flatMapLatest { (service.activate(with: $0).materialize()) }
            .share()
            .print()
        
        result.values()
            .compactMap { $0.ios }
            .sink { [weak self] in
                if Decimal(string: $0) ?? 0 > 6.1 {
                    self?.stateTitle = State.activated.title
                } else {
                    self?.showError = "Activation was not successful!"
                }
            }
            .store(in: &cancellables)
        
        result.failures()
            .map { $0.localizedDescription }
            .assign(to: &$showError)
        
        subscribeGenerateCode
            .sink { [weak self] in
                guard let self else { return }
                self.generateCodeAction = self.shouldGenerateCode
                    .delay(for: 2, scheduler: RunLoop.current)
                    .sink {
                        self.generatedCode = UUID().uuidString
                        self.stateTitle = State.scratched.title
                        self.isScratchEnabled = false
                    }
            }.store(in: &cancellables)
        
        $generatedCode
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .map { _ in true }
            .removeDuplicates()
            .assign(to: &$isActivationEnabled)
        
        cancelGenerateCode
            .sink { [weak self] _ in self?.generateCodeAction?.cancel() }
            .store(in: &cancellables)
        
        $showError
            .compactMap { $0 }
            .sink {
                let content = UNMutableNotificationContent()
                content.title = "Activation failed!"
                content.subtitle = $0
                content.sound = UNNotificationSound.defaultCritical
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request)
            }.store(in: &cancellables)
    }
}
