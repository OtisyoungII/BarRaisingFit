//
//  BarRaisinfFitapp.swift
//  BarRaisingFit
//
//  Created by Otis Young on 7/12/25.
//

import SwiftUI

@main
struct BarRaisinfFitapp: App {
    @StateObject private var profileVM = UserProfileViewModel()
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            if showSplash {
                SplashScreenView()
                    .onAppear {
                        // Delay showing the main content for 4 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                            withAnimation {
                                showSplash = false
                            }
                        }
                    }
            } else {
                Homer()
                    .environmentObject(profileVM)
            }
        }
    }
}
