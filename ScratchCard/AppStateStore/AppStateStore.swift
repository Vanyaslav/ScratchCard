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

final class AppStateStore: NSObject, ObservableObject {
    // private
    private var cancellables = Set<AnyCancellable>()
    private var generateCodeAction: Cancellable?
    private let generateCode = PassthroughRelay<Void>()
    // in
    let subscribeGenerateCode = PassthroughRelay<Void>()
    let cancelGenerateCode = PassthroughRelay <Void>()
    let shouldGenerateCode = PassthroughRelay<Void>()
    let shouldActivate = PassthroughRelay<Void>()
    let shouldDeactivate = PassthroughRelay<Void>()
    // out
    @Published private(set) var stateTitle: String
    @Published private(set) var isActivationEnabled: Bool
    @Published private(set) var isDeactivationEnabled: Bool
    @Published private(set) var isScratchEnabled: Bool
    @Published private(set) var generatedCode: String?
    
    init(
        dataService: DataServiceProtocol = DataService(),
        alertService: NotificationProtocol = NotificationService(),
        initialState: State = .init()
    ) {
        stateTitle = initialState.title
        isActivationEnabled = initialState.enableActivation
        isScratchEnabled = initialState.enableScratch
        isDeactivationEnabled = initialState.enableDeactivation
        super.init()
        
        alertService.register.accept(self)
        
        let activationResult = shouldActivate
            .withLatestFrom($generatedCode)
            .compactMap { $0 }
            .flatMapLatest { dataService.activate(with: $0).materialize() }
            .print()
        
        let state = Publishers.Merge5(
            activationResult
                .map(State.Action.process),
            generateCode
                .map(State.Action.generateCode),
            shouldDeactivate
                .map(State.Action.deactivate),
            shouldGenerateCode
                .map(State.Action.startGenerateCode),
            cancelGenerateCode
                .map(State.Action.cancelGenerateCode)
        )
            .receive(on: DispatchQueue.main)
            .scan(initialState) { $0.apply($1) }
            .share()
        
        state.bind(\.title, to: &$stateTitle)
        state.bind(\.enableScratch, to: &$isScratchEnabled)
        state.bind(\.enableActivation, to: &$isActivationEnabled)
        state.bind(\.generatedCode, to: &$generatedCode)
        state.bind(\.enableDeactivation, to: &$isDeactivationEnabled)
        state.compactMap { $0.errorResponse }
            .removeDuplicates()
            .map { $0.message }
            .sink { alertService.showAlert.accept($0) }
            .store(in: &cancellables)
        
        subscribeGenerateCode
            .sink { _ in
                self.generateCodeAction = self.shouldGenerateCode
                    .delay(for: self.simulateScratchTime,
                           scheduler: RunLoop.current)
                    .sink { self.generateCode.accept() }
            }.store(in: &cancellables)
        
        cancelGenerateCode
            .sink { _ in self.generateCodeAction?.cancel() }
            .store(in: &cancellables)
    }
}
