//
//  View+Ext.swift
//  ScratchCard
//
//  Created by Tomas Baculák on 07/05/2023.
//

import SwiftUI

extension View {
    func enabled(_ isEnabled: Bool) -> some View {
        disabled(!isEnabled)
            .opacity(isEnabled
                     ? 1
                     : 0.3)
    }
}
