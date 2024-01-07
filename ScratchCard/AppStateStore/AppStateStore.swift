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

extension AppStateStore {
    // in seconds
    var simulateScratchTime: RunLoop.SchedulerTimeType.Stride { 2 }
}

extension PassthroughRelay {
    func focus(on action: AppStateStore.Action) -> AnyPublisher<(), Never> {
        filter { $0 as? AppStateStore.Action == action }
            .mapToVoid()
            .eraseToAnyPublisher()
    }
}

final class AppStateStore: NSObject, ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    private var generateCodeAction: Cancellable?
    // in
    let send = PassthroughRelay<Action>()
    // out
    @Published private(set) var state: State
    
    init(
        dataService: DataServiceProtocol = DataService(),
        alertService: NotificationProtocol = NotificationService(),
        initialState: State = .init()
    ) {
        state = initialState
        super.init()
        
        alertService.register.accept(self)
        
        let activationResult = send.focus(on: .shouldActivate)
            .withLatestFrom($state)
            .compactMap { $0.generatedCode }
            .flatMapLatest { dataService.activate(with: $0).materialize() }
            .print()
        
        let state = Publishers.Merge(
            activationResult.map(Action.process),
            send
        )
            .receive(on: DispatchQueue.main)
            .scan(state) { $0.apply($1) }
            .removeDuplicates()
            .share()
        
        state.assign(to: &$state)
        
        state.compactMap { $0.errorResponse }
            .removeDuplicates()
            .map { $0.message }
            .print("Error message")
            .sink(receiveValue: alertService.showAlert.accept)
            .store(in: &cancellables)
        
        send.focus(on: .subscribeGenerateCode)
            .sink(receiveValue: subscribeDelayedScratchingAction)
            .store(in: &cancellables)

        send.focus(on: .cancelGenerateCode)
            .sink(receiveValue: cancelDelayedScratchingAction)
            .store(in: &cancellables)
    }
}

extension AppStateStore {
    private func subscribeDelayedScratchingAction() {
        generateCodeAction = send.focus(on: .startGenerateCode)
            .delay(for: simulateScratchTime, scheduler: RunLoop.current)
            .map { .generateCode }
            .sink(receiveValue: send.accept)
    }
    
    private func cancelDelayedScratchingAction() {
        generateCodeAction?.cancel()
        generateCodeAction = nil
    }
}
