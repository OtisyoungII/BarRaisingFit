//
//  BarRaisinfFitapp.swift
//  BarRaisingFit
//
//  Created by Otis Young on 7/12/25.
//

import SwiftUI

@main
struct BarRaisingFitapp: App {
    @StateObject private var profileVM = UserProfileViewModel()
    @StateObject private var authVM = AuthViewModel()
    @StateObject private var appState = AppState()
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            if showSplash {
                SplashScreenView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                            withAnimation {
                                showSplash = false
                            }
                        }
                    }
            } else {
                Homer()
                    .environmentObject(authVM)
                    .environmentObject(profileVM)
                    .environmentObject(appState)
            }
        }
    }
}
