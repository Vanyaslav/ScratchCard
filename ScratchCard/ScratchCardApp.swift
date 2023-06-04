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
    @StateObject private var router: AppRouter = .init()
    
    var body: some Scene {
        WindowGroup {
            router
                .mainView()
                .environmentObject(router)
        }
    }
}
