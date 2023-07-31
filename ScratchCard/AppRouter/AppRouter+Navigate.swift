//
//  AppRouter+Navigate.swift
//  ScratchCard
//
//  Created by Tomas Baculák on 04/06/2023.
//

import SwiftUI

extension AppRouter {
    func navigateActivationView(with view: some View) -> NavigationLink<some View, ActivationView> {
        .init(destination: .init()) { view }
    }
    
    func navigateScratchView(with view: some View) -> NavigationLink<some View, ScratchCardView> {
        .init(destination: .init()) { view }
    }
    
    func navigateScratchConfirmView(with view: some View) -> NavigationLink<some View, ScratchConfirmView> {
        .init(destination: .init()) { view }
    }
}
