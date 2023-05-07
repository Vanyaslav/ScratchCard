//
//  MainView.swift
//  ScratchCard
//
//  Created by Tomas Baculák on 06/05/2023.
//

import SwiftUI
import Resolver

struct MainView: View {
    @InjectedObject var store: AppStateStore
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text(store.stateTitle)
                    .formatStateText()
                Spacer()
                NavigationLink(destination: ScratchCardView()) {
                    Text("Scratch card")
                        .formatButtonText()
                }
                NavigationLink(destination: ActivationView()) {
                    Text("Activation")
                        .formatButtonText()
                }
            }.padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
