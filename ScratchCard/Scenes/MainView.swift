//
//  MainView.swift
//  ScratchCard
//
//  Created by Tomas Baculák on 06/05/2023.
//

import SwiftUI
import Resolver

struct MainView: View {
    @EnvironmentObject 
    private var router: AppRouter
    
    @InjectedObject 
    private var store: AppStateStore
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                MainTitle()
                DeactivationButton()
                Spacer()
                if store.state.isScratched {
                    router.navigateScratchView(with: ScratchButton())
                } else {
                    router.navigateScratchConfirmView(with: ScratchButton())
                }
                router.navigateActivationView(with: ActivationButton())
            }.padding()
        }
    }
}

extension MainView {
    func MainTitle() -> some View {
        Text(store.state.title)
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
            .onTapGesture { store.send.accept(.deactivate) }
            .enabled(store.state.enableDeactivation)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
