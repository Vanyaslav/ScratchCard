//
//  ScratchCardView.swift
//  ScratchCard
//
//  Created by Tomas Baculák on 07/05/2023.
//

import SwiftUI
import Resolver

struct ScratchCardView: View {
    @InjectedObject var store: AppStateStore
    
    var body: some View {
        VStack {
            Spacer()
            Button { store.shouldGenerateCode.send() } label: {
                Text("Scratch the card")
                    .formatButtonText()
            }
        }
        .padding()
        .onAppear() {
            store.subscribeGenerateCode.send()
        }
        .onDisappear() {
            store.cancelGenerateCode.send()
        }
        .enabled(store.isScratchEnabled)
    }
}

struct ScratchCardView_Previews: PreviewProvider {
    static var previews: some View {
        ScratchCardView()
    }
}
