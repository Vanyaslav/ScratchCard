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
    // out
    @Published private(set) var stateTitle: String
    @Published private(set) var isActivationEnabled: Bool
    @Published private(set) var isScratchEnabled: Bool
    @Published private(set) var generatedCode: String?
    @Published private(set) var showError: String?
    
    init(
        service: DataServiceProtocol = DataService(),
        initialState: State = .init()
    ) {
        stateTitle = initialState.title
        isActivationEnabled = initialState.enableActivation
        isScratchEnabled = initialState.enableScratch
        super.init()
        
        UNUserNotificationCenter
            .requestAndDelegate(object: self)
        
        let result = shouldActivate
            .withLatestFrom($generatedCode)
            .compactMap { $0 }
            .flatMapLatest { service.activate(with: $0).materialize() }
            .receive(on: DispatchQueue.main)
            .share()
            .print()
        
        let state = Publishers.Merge3(
            result.values()
                .map(State.Action.processActivationData),
            result.failures()
                .map(State.Action.processActivationError),
            generateCode
                .map { _ in State.Action.generateCode }
        )
            .scan(initialState) { $0.apply($1) }
            .share()
        
        state.bind(\.title, to: &$stateTitle)
        state.bind(\.enableScratch, to: &$isScratchEnabled)
        state.bind(\.enableActivation, to: &$isActivationEnabled)
        state.bind(\.generatedCode, to: &$generatedCode)
        state.compactMap { $0.errorResponse }
            .removeDuplicates()
            .map { $0.message }
            .assign(to: &$showError)
        
        $showError
            .compactMap { $0 }
            .sink { UNUserNotificationCenter.sendNotification(subTitle: $0) }
            .store(in: &cancellables)
        
        subscribeGenerateCode
            .sink { [weak self] in
                guard let self else { return }
                self.generateCodeAction = self.shouldGenerateCode
                    .delay(for: self.simulateScratchTime,
                           scheduler: RunLoop.current)
                    .sink {
                        self.generateCodeAction?.cancel()
                        self.generateCode.accept()
                    }
            }.store(in: &cancellables)
        
        cancelGenerateCode
            .sink { [weak self] in self?.generateCodeAction?.cancel() }
            .store(in: &cancellables)
    }
}
