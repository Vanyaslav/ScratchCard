//
//  CodeActivationState.swift
//  ScratchCard
//
//  Created by Tomas Baculák on 24/05/2023.
//

import Foundation

extension CodeActivationState {
    static var initial: Self {
        .unscratched
    }
}

enum CodeActivationState: String {
    case unscratched, scratched, activated, deactivated
    
    var title: String {
        switch self {
        case .unscratched:
            return "Unscratched"
            
        case .scratched:
            return "Scratched"
            
        case .activated:
            return "Activated"
            
        case .deactivated:
            return "Deactivated"
        }
    }
}
