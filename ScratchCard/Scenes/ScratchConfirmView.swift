//
//  ScratchConfirmView.swift
//  ScratchCard
//
//  Created by Tomas Baculák on 07/06/2023.
//

import SwiftUI

struct ScratchConfirmView: View {
    @EnvironmentObject private var router: AppRouter
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Spacer()
            DescriptionView()
            Spacer()
            HStack {
                DeclineButton()
                router.navigateScratchView(with: ConfirmButton())
            }
        }.padding()
    }
}
extension ScratchConfirmView {
    func DescriptionView() -> some View {
        Text("This page takes you to the scratch generator view. \n \n Would you like to continue?")
            .multilineTextAlignment(.center)
    }
    
    func ConfirmButton() -> some View {
        Text("YES")
            .formatButtonText()
    }
    
    func DeclineButton() -> some View {
        Button { dismiss() } label: {
            Text("NO")
                .formatButtonText()
        }
    }
}

struct ScratchConfirmView_Previews: PreviewProvider {
    static var previews: some View {
        ScratchConfirmView()
    }
}
