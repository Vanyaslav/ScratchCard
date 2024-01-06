//
//  ActivationView.swift
//  ScratchCard
//
//  Created by Tomas Baculák on 06/05/2023.
//

import SwiftUI
import Resolver

struct ActivationView: View {
    @InjectedObject 
    private var store: AppStateStore
    
    var body: some View {
        VStack {
            Spacer()
            Button { store.send.accept(.shouldActivate) } label: {
                Text("Activate")
                    .formatButtonText()
            }
            .enabled(store.state.enableActivation)
        }
        .padding()
    }
}

struct ActivationView_Previews: PreviewProvider {
    static var previews: some View {
        ActivationView()
    }
}
