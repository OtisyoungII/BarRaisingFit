//
//  BarRaisinfFitapp.swift
//  BarRaisingFit
//
//  Created by Otis Young on 7/12/25.
//

import SwiftUI

@main
struct YourApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject private var auth = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            Homer() // Your SwiftUI root view
                .environmentObject(auth)
        }
    }
}
