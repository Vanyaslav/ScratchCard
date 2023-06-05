//
//  Publisher+AppStateStore.State.swift
//  ScratchCard
//
//  Created by Tomas Baculák on 05/06/2023.
//

import Foundation
import Combine

extension Publisher where Output == AppStateStore.State {
    func bind<T>(
        _ keyPath: KeyPath<Output, T>,
        to publisher: inout Published<T>.Publisher
    ) where T: Equatable {
        map(keyPath)
            .removeDuplicates()
            .ignoreFailure()
            .receive(on: DispatchQueue.main)
            .assign(to: &publisher)
    }
}
