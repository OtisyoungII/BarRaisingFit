//
//  SplashScreen.swift
//  BarRaisingFit
//
//  Created by Otis Young on 7/12/25.
//

import SwiftUI

struct SplashScreenView: View {
    var body: some View {
        ZStack {
            Color("LaunchBackgroundColor") // Match your LaunchScreen background color
                .ignoresSafeArea()

            Image("LaunchImage") // Optional: same image as your LaunchScreen
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
        }
    }
}

