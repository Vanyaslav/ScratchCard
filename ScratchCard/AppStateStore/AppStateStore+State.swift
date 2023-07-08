//
//  AppStateStore+State.swift
//  ScratchCard
//
//  Created by Tomas Baculák on 17/05/2023.
//

import Foundation
import CombineExt

extension AppStateStore.State {
    enum Action {
        case generateCode(id: Void),
             startGenerateCode(id: Void),
             cancelGenerateCode(id: Void),
             process(_ response: Event<VersionResponse, Swift.Error>),
             deactivate(id: Void)
    }
}

extension AppStateStore {
    struct State {
        private var activationState: CodeActivationState {
            didSet {
                title = activationState.title
                
                switch activationState {
                case .unscratched:
                    break
                    
                case .scratched:
                    generatedCode = UUID().uuidString
                    enableScratch = false
                    enableActivation = true
                    
                case .activated:
                    enableDeactivation = true
                    enableActivation = false
                    
                case .deactivated:
                    enableDeactivation = false
                    enableActivation = true
                }
            }
        }
        
        private(set) var title: String
        private(set) var enableActivation: Bool
        private(set) var enableDeactivation: Bool
        private(set) var enableScratch: Bool
        private(set) var errorResponse: ErrorResponse?
        private(set) var generatedCode: String?
    }
}

extension AppStateStore.State {
    init(
        activationState: CodeActivationState = .initial,
        enableScratch: Bool = true,
        enableActivation: Bool = false,
        enableDeactivation: Bool = false
    ) {
        self.activationState = activationState
        self.title = activationState.title
        self.enableScratch = enableScratch
        self.enableActivation = enableActivation
        self.enableDeactivation = enableDeactivation
    }
}

extension AppStateStore.State {
    func apply(_ action: Action) -> Self {
        var state = self
        switch action {
        case .generateCode:
            state.activationState = .scratched
            
        case .deactivate:
            state.manageDeactivation("The Coupon was deactivated!")
            
        case .startGenerateCode:
            state.enableScratch = false
            
        case .cancelGenerateCode:
            state.enableScratch = state.generatedCode == nil
            
        case .process(let response):
            switch response {
            case .value(let data):
                if let version = data.ios,
                   Decimal(string: version) ?? 0 > 6.1 {
                    state.activationState = .activated
                } else {
                    state.manageDeactivation("Activation was not successful!")
                }
                
            case .failure(let error):
                state.manageError(message: error.localizedDescription)
                
            case .finished:
                break
            }
        }
        return state
    }
}

extension AppStateStore.State {
    private mutating func manageDeactivation(_ message: String) {
        activationState = .deactivated
        manageError(message: message)
    }
    
    private mutating func manageError(message: String) {
        errorResponse = .init(count: (errorResponse?.count ?? 0) + 1,
                              message: message)
    }
}

struct ErrorResponse: Equatable {
    let count: Int
    let message: String
}
