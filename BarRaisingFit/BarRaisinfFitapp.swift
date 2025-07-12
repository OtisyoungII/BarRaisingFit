//
//  BarRaisinfFitapp.swift
//  BarRaisingFit
//
//  Created by Otis Young on 7/12/25.
//

import SwiftUI

@main
struct BarRaisinfFitapp: App {
//    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var profileVM = UserProfileViewModel()

    var body: some Scene {
        WindowGroup {
            Homer()
                .environmentObject(profileVM)
        }
    }
}
