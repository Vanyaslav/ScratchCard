//
//  ScratchCardView.swift
//  ScratchCard
//
//  Created by Tomas Baculák on 07/05/2023.
//

import SwiftUI
import Resolver

protocol ScratchCard: View {}

struct ScratchCardView: ScratchCard {
    @InjectedObject 
    private var store: AppStateStore
    
    var body: some View {
        VStack {
            if let code = store.state.generatedCode {
                CodeView(code)
            }
            Spacer()
            AcceptButton()
        }
        .padding()
        .onAppear() {
            store.send.accept(.subscribeGenerateCode)
        }
        .onDisappear() {
            store.send.accept(.cancelGenerateCode)
        }
    }
}

extension ScratchCardView {
    func CodeView(_ code: String) -> some View {
        VStack {
            Text("Scratched code:")
                .padding(.bottom, 16)
            Text(code)
        }
    }
    
    func AcceptButton() -> some View {
        Button { store.send.accept(.startGenerateCode) } label: {
            Text("Scratch the card")
                .formatButtonText()
        }.enabled(store.state.enableScratch)
    }
}

struct ScratchCardView_Previews: PreviewProvider {
    static var previews: some View {
        ScratchCardView()
    }
}
