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
            Button { store.shouldGenerateCode.accept() } label: {
                Text("Scratch the card")
                    .formatButtonText()
            }.enabled(store.isScratchEnabled)
        }
        .padding()
        .onAppear() {
            store.subscribeGenerateCode.accept()
        }
        .onDisappear() {
            store.cancelGenerateCode.accept()
        }
    }
}

struct ScratchCardView_Previews: PreviewProvider {
    static var previews: some View {
        ScratchCardView()
    }
}
