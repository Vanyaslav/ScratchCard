//
//  CodeActivationState.swift
//  ScratchCard
//
//  Created by Tomas Baculák on 24/05/2023.
//

import Foundation

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
