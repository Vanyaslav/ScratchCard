//
//  AppStateStore.swift
//  ScratchCard
//
//  Created by Tomas Baculák on 06/05/2023.
//

import Foundation
import Combine
import CombineExt

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

final class AppStateStore: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    // in
    let shouldGenerateCode = PassthroughSubject<Void, Never>()
    let cancelGenerateCode = PassthroughSubject<Void, Never>()
    let subscribeGenerateCode = PassthroughSubject<Void, Never>()
    let shouldActivate = PassthroughSubject<Void, Never>()
    // out
    @Published private(set) var stateTitle: String
    // dummy
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
        
        let result = shouldActivate
            .withLatestFrom($generatedCode)
            .compactMap { $0 }
            .flatMapLatest { (service.activate(with: $0).materialize()) }
            .share()
            .print()
        
        result.values()
            .compactMap { $0.ios }
            .filter { Decimal(string: $0) ?? 0 > 6.1  }
            .map {_ in State.activated.title }
            .assign(to: &$stateTitle)
        
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
    }
}
