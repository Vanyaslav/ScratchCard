//
//  AppRouter.swift
//  ScratchCard
//
//  Created by Tomas Baculák on 02/06/2023.
//

import SwiftUI
import Resolver

protocol RouterProtocol {
    associatedtype T: View
    func mainView() -> T
}

extension AppRouter: RouterProtocol {
    func mainView() -> some View {
        MainView(router: self)
    }
}

final class AppRouter {
    init() {
        Resolver.registerAllServices()
    }
}

extension Resolver: ResolverRegistering {
    public static func registerAllServices() {
        register { AppStateStore() }.scope(.shared)
    }
}
