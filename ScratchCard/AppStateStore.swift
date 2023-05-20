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

enum CodeActivationState: String {
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

final class AppStateStore: NSObject, ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    // in
    let shouldGenerateCode = PassthroughRelay<Void>()
    let cancelGenerateCode = PassthroughRelay <Void>()
    let subscribeGenerateCode = PassthroughRelay<Void>()
    let shouldActivate = PassthroughRelay<Void>()
    //
    private static let storeState = State()
    // out
    @Published private(set) var stateTitle: String = storeState.title
    @Published private(set) var isActivationEnabled: Bool = storeState.enableActivation
    @Published private(set) var isScratchEnabled: Bool = storeState.enableScratch
    
    @Published private(set) var generatedCode: String?
    
    private var generateCodeAction: Cancellable?
    private let generateCode = PassthroughRelay<Void>()
    
    init(
        service: DataServiceProtocol = DataService(),
        initialCode: String? = nil
    ) {
        self.generatedCode = initialCode
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
        
        let state = Publishers
            .Merge3(
                result.values()
                    .map(State.Action.processActivationData),
                result.failures()
                    .map(State.Action.processActivationError),
                generateCode
                    .map { _ in State.Action.generateCode }
            )
            .scan(Self.storeState) { $0.apply($1) }
            .share()
        
        state.map { $0.title }.removeDuplicates().assign(to: &$stateTitle)
        state.map { $0.enableScratch }.removeDuplicates().assign(to: &$isScratchEnabled)
        state.map { $0.enableActivation }.removeDuplicates().assign(to: &$isActivationEnabled)
        state.map { $0.generatedCode }.removeDuplicates().assign(to: &$generatedCode)
        
        state.map { $0.errorResponse }
            .removeDuplicates { $0?.0 == $1?.0 }
            .compactMap { $0?.1 }
            .sink {
                UNUserNotificationCenter
                    .sendNotification(subTitle: $0) }
            .store(in: &cancellables)
        
        subscribeGenerateCode
            .sink { [weak self] in
                guard let self else { return }
                self.generateCodeAction = self.shouldGenerateCode
                    .delay(for: 2, scheduler: RunLoop.current)
                    .sink { self.generateCode.accept() }
            }.store(in: &cancellables)
        
        cancelGenerateCode
            .sink { [weak self] in self?.generateCodeAction?.cancel() }
            .store(in: &cancellables)
    }
}
