//
//  ActivationView.swift
//  ScratchCard
//
//  Created by Tomas Baculák on 06/05/2023.
//

import SwiftUI
import Resolver

struct ActivationView: View {
    @InjectedObject var store: AppStateStore
    
    var body: some View {
        VStack {
            Spacer()
            Button { store.shouldActivate.accept() } label: {
                Text("Activate")
                    .formatButtonText()
            }
            .enabled(store.isActivationEnabled)
        }
        .padding()
    }
}

struct ActivationView_Previews: PreviewProvider {
    static var previews: some View {
        ActivationView()
    }
}
