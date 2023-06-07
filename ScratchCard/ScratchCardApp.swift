//
//  ScratchCardApp.swift
//  ScratchCard
//
//  Created by Tomas Baculák on 06/05/2023.
//

import SwiftUI
import Resolver

@main
struct ScratchCardApp: App {
    var body: some Scene {
        WindowGroup {
            AppRouter()
                .mainView()
        }
    }
}
