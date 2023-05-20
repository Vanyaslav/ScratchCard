//
//  AppStateStore+State.swift
//  ScratchCard
//
//  Created by Tomas Baculák on 17/05/2023.
//

import Foundation

extension AppStateStore.State {
    static var initial: Self {
        .init(
            state: .unscratched,
            enableActivation: false,
            enableScratch: true
        )
    }
}

extension AppStateStore.State {
    private init(
        state: CodeActivationState,
        enableActivation: Bool,
        enableScratch: Bool
    ) {
        self.state = state
        self.title = state.title
        self.enableActivation = enableActivation
        self.enableScratch = enableScratch
    }
    
    init(
        state: Self = .initial
    ) {
        self.state = state.state
        self.title = state.state.title
        self.enableActivation = state.enableActivation
        self.enableScratch = state.enableScratch
    }
}

extension AppStateStore.State {
    func apply(_ action: Action) -> Self {
        var state = self
        switch action {
        case .generateCode:
            state.generatedCode = UUID().uuidString
            state.state = .scratched
            state.enableScratch = false
            state.enableActivation = true
            
        case .processActivationData(let data):
            if let version = data.ios,
               Decimal(string: version) ?? 0 > 6.1 {
                state.state = .activated
            } else {
                state.failureCount += 1
                state.errorResponse = (state.failureCount, "Activation was not successful!")
            }
            
        case .processActivationError(let error):
            state.failureCount += 1
            state.errorResponse = (state.failureCount, error.localizedDescription)
            
        }
        return state
    }
}

extension AppStateStore.State {
    enum Action {
        case generateCode,
             processActivationData(_ data: VersionResponse),
             processActivationError(_ error: Swift.Error)
    }
}

extension AppStateStore {
    struct State {
        private var state: CodeActivationState {
            didSet {
                title = state.title
            }
        }
        
        private var failureCount: Int = 0
        
        private(set) var title: String
        private(set) var enableActivation: Bool
        private(set) var enableScratch: Bool
        private(set) var errorResponse: (Int, String)?
        private(set) var generatedCode: String?
    }
}
