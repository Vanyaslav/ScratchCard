//
//  MainView.swift
//  ScratchCard
//
//  Created by Tomas Baculák on 06/05/2023.
//

import SwiftUI
import Resolver

struct MainView: View {
    @EnvironmentObject private var router: AppRouter
    @InjectedObject private var store: AppStateStore
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                mainTitle()
                Spacer()
                router.navigateScratchView(text: scratchButton)
                router.navigateActivationView(text: activationButton)
            }.padding()
        }
    }
}

extension MainView {
    func mainTitle() -> some View {
        Text(store.stateTitle)
            .formatStateText()
    }
    
    var scratchButton: some View {
        Text("Scratch card")
            .formatButtonText()
    }
    
    var activationButton: some View {
        Text("Activation")
            .formatButtonText()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(AppRouter())
    }
}
