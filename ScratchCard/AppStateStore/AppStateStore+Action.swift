//
//  AppStateStore+Action.swift
//  ScratchCard
//
//  Created by Tomas Baculák on 06/01/2024.
//

import Foundation
import CombineExt

extension AppStateStore {
    enum Action {
        case generateCode,
             subscribeGenerateCode,
             startGenerateCode,
             cancelGenerateCode,
             process(_ response: Event<VersionResponse, Swift.Error>),
             deactivate,
             shouldActivate
    }
}

extension AppStateStore.Action: Equatable {
    static func == (
        lhs: AppStateStore.Action,
        rhs: AppStateStore.Action
    ) -> Bool {
        switch (lhs, rhs) {
        case
            (.generateCode, .generateCode),
            (.startGenerateCode, .startGenerateCode),
            (.subscribeGenerateCode, .subscribeGenerateCode),
            (.cancelGenerateCode, .cancelGenerateCode),
            (.shouldActivate, .shouldActivate),
            (.deactivate, .deactivate):
            return true
            
        case (.process(let lhsEvent), .process(let rhsEvent)):
            return lhsEvent.description == rhsEvent.description
            
        default:
            return false
        }
    }
}
