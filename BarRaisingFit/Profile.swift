//
//  Profile.swift
//  BarRaisingFit
//
//  Created by Otis Young on 7/12/25.
//

import SwiftUI

struct Profile: View {
    @EnvironmentObject var auth: AuthViewModel

    var body: some View {
        VStack(spacing: 20) {
            if auth.isAuthenticated, let user = auth.userInfo {
                // Welcome message
                Text("Welcome, \(user.name ?? "User")!")
                    .font(.title)
                    .fontWeight(.semibold)

                // User profile picture
                if let picture = user.picture, let url = URL(string: picture) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                    } placeholder: {
                        ProgressView()
                    }
                }

                // Logout button
                Button(action: {
                    auth.logout()
                }) {
                    Text("Logout")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

            } else {
                // Login button
                Button(action: {
                    auth.login()
                }) {
                    Text("Login with Auth0")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .navigationTitle("Profile")
    }
}

#Preview {
    Profile().environmentObject(AuthViewModel())
}
