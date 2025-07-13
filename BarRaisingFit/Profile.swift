//
//  Profile.swift
//  BarRaisingFit
//
//  Created by Otis Young on 7/12/25.
//

import SwiftUI

struct Profile: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var profileVM: UserProfileViewModel

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    if !authVM.isAuthenticated {
                        // 🚪 Show login prompt
                        VStack(spacing: 16) {
                            Text("🔐 Please Sign In")
                                .font(.title)
                                .bold()

                            Button("Log In") {
                                authVM.login {
                                    profileVM.updateProfilePicture(with: authVM.userName, picture: authVM.profilePictureURL)
                                }
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .frame(maxWidth: .infinity)
                        .padding()

                    } else {
                        // ✅ User is signed in — safe to access profile info
                        Text("👤 Profile")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        if let url = authVM.profilePictureURL {
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

                        HStack {
                            VStack(alignment: .leading) {
                                Text("Name: \(authVM.userName)")
                                Text("Age: \(profileVM.profile.age)")
                                if let gender = profileVM.profile.gender {
                                    Text("Gender: \(gender)")
                                }
                            }
                            Spacer()
                        }
                        .font(.headline)

                        Divider()

                        VStack(alignment: .leading, spacing: 10) {
                            Text("📏 Height: \(String(format: "%.1f", profileVM.profile.heightInInches)) in")
                            Text("⚖️ Weight: \(String(format: "%.1f", profileVM.profile.weightInPounds)) lbs")
                            Text("📊 BMI: \(String(format: "%.1f", profileVM.profile.bmi))")
                        }

                        Divider()

                        VStack(alignment: .leading, spacing: 10) {
                            if let goal = profileVM.profile.goal {
                                Text("🎯 Goal: \(goal)")
                            }
                            Text("📅 Joined: \(profileVM.profile.dateJoined, formatter: dateFormatter)")
                        }

                        Button("Log Out") {
                            authVM.logout()
                            profileVM.resetToDefault()
                        }
                        .padding(.top)
                        .foregroundColor(.red)
                    }
                }
                .padding()
            }
            .navigationTitle("Your Profile")
        }
    }

    private var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df
    }
}

#Preview {
    Profile()
        .environmentObject(AuthViewModel()) // ✅ Inject correct view model for preview
}
