//
//  ScratchCardView.swift
//  ScratchCard
//
//  Created by Tomas Baculák on 07/05/2023.
//

import SwiftUI
import Resolver

struct ScratchCardView: View {
    @InjectedObject private var store: AppStateStore
    
    var body: some View {
        VStack {
            if let code = store.generatedCode {
                codeView(code)
            }
            Spacer()
            acceptButton()
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

extension ScratchCardView {
    func codeView(_ code: String) -> some View {
        VStack {
            Text("Scratched code:")
                .padding(.bottom, 16)
            Text(code)
        }
    }
    
    func acceptButton() -> some View {
        Button { store.shouldGenerateCode.accept() } label: {
            Text("Scratch the card")
                .formatButtonText()
        }.enabled(store.isScratchEnabled)
    }
}

struct ScratchCardView_Previews: PreviewProvider {
    static var previews: some View {
        ScratchCardView()
    }
}
