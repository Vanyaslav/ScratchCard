//
//  AppStateStore+State.swift
//  ScratchCard
//
//  Created by Tomas Baculák on 17/05/2023.
//

import Foundation

extension AppStateStore.State {
    enum Action {
        case generateCode,
             processActivationData(_ data: VersionResponse),
             processActivationError(_ error: Swift.Error)
    }
}

extension AppStateStore {
    struct State {
        private var activationState: CodeActivationState {
            didSet {
                title = activationState.title
            }
        }
        
        private var failureCount: Int = 0
        
        private(set) var title: String
        private(set) var enableActivation: Bool
        private(set) var enableScratch: Bool
        private(set) var errorResponse: ErrorResponse?
        private(set) var generatedCode: String?
    }
}

extension AppStateStore.State {
    init(
        activationState: CodeActivationState = .initial,
        enableActivation: Bool = false,
        enableScratch: Bool = true
    ) {
        self.activationState = activationState
        self.title = activationState.title
        self.enableActivation = enableActivation
        self.enableScratch = enableScratch
    }
}

extension AppStateStore.State {
    func apply(_ action: Action) -> Self {
        var state = self
        switch action {
        case .generateCode:
            state.generatedCode = UUID().uuidString
            state.activationState = .scratched
            state.enableScratch = false
            state.enableActivation = true
            
        case .processActivationData(let data):
            if let version = data.ios,
               Decimal(string: version) ?? 0 > 6.1 {
                state.activationState = .activated
            } else {
                state.failureCount += 1
                state.errorResponse = .init(count: state.failureCount,
                                            message: "Activation was not successful!")
            }
            
        case .processActivationError(let error):
            state.failureCount += 1
            state.errorResponse = .init(count: state.failureCount,
                                        message: error.localizedDescription)
        }
        return state
    }
}

struct ErrorResponse: Equatable {
    let count: Int
    let message: String
}
