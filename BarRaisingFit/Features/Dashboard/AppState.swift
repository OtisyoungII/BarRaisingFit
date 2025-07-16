//
//  AppState.swift
//  BarRaisingFit
//
//  Created by Otis Young on 7/16/25.
//

import SwiftUI

class AppState: ObservableObject {
    enum Mode {
        case guest
        case signedIn
    }

    @Published var mode: Mode = .guest
}
