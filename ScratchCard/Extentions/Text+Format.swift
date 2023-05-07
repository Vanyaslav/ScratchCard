//
//  Text+Format.swift
//  ScratchCard
//
//  Created by Tomas Baculák on 06/05/2023.
//

import SwiftUI

extension Text {
    func formatButtonText() -> some View {
        font(.title)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(.teal)
            .clipShape(Capsule())
            .padding([.leading, .trailing], 16)
    }
    
    func formatStateText() -> some View {
        font(.largeTitle)
            .foregroundColor(Color(.label))
    }
}
