//
//  AppRouter+Navigate.swift
//  ScratchCard
//
//  Created by Tomas Baculák on 04/06/2023.
//

import SwiftUI

extension AppRouter {
    func navigateActivationView(with text: some View) -> NavigationLink<some View, ActivationView> {
        .init(destination: ActivationView()) {
            text
        }
    }
    
    func navigateScratchView(with text: some View) -> NavigationLink<some View, ScratchCardView> {
        .init(destination: ScratchCardView()) {
            text
        }
    }
}
