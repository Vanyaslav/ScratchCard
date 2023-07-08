//
//  MainView.swift
//  ScratchCard
//
//  Created by Tomas Baculák on 06/05/2023.
//

import SwiftUI
import Resolver

struct MainView: View {
    private let router: AppRouter
    @InjectedObject private var store: AppStateStore
    
    init(router: AppRouter) {
        self.router = router
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                MainTitle()
                DeactivationButton()
                Spacer()
                router.navigateScratchConfirmView(with: ScratchButton())
                router.navigateActivationView(with: ActivationButton())
            }.padding()
        }
    }
}

extension MainView {
    func MainTitle() -> some View {
        Text(store.stateTitle)
            .formatStateText()
    }
    
    func ScratchButton() -> some View {
        Text("Scratch card")
            .formatButtonText()
    }
    
    func ActivationButton() -> some View {
        Text("Activation")
            .formatButtonText()
    }
    
    func DeactivationButton() -> some View {
        Text("Deactivate")
            .formatButtonText()
            .onTapGesture { store.shouldDeactivate.accept() }
            .enabled(store.isDeactivationEnabled)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(router: AppRouter())
    }
}
