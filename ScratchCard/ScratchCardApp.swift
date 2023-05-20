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

extension Resolver: ResolverRegistering {
    public static func registerAllServices() {
        register { AppStateStore() }.scope(.shared)
    }
}

final class AppRouter {
    init() {
        Resolver.registerAllServices()
    }
}

extension AppRouter {
    func mainView() -> some View {
        MainView()
    }
}
