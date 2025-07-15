//
//  Profile.swift
//  BarRaisingFit
//
//  Created by Otis Young on 7/12/25.
//

import SwiftUI

struct Profile: View {
    @EnvironmentObject var profileVM: UserProfileViewModel
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                // Profile image
                if authVM.isAuthenticated, let url = profileVM.profile.profilePictureURL {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 120, height: 120)
                        case .success(let image):
                            image.resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                        case .failure:
                            Image(systemName: "person.crop.circle.badge.exclamationmark")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 120, height: 120)
                                .foregroundColor(.gray)
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .foregroundColor(.gray)
                }

                // Name
                Text(profileVM.profile.name)
                    .font(.title)
                    .bold()

                if authVM.isAuthenticated {
                    // Age & Gender
                    HStack(spacing: 40) {
                        VStack {
                            Text("Age")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(profileVM.profile.age)")
                                .font(.headline)
                        }

                        VStack {
                            Text("Gender")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(profileVM.profile.gender ?? "N/A")
                                .font(.headline)
                        }
                    }

                    // Height / Weight / BMI
                    VStack(spacing: 10) {
                        Text("Height: \(profileVM.profile.heightInFeet) ft \(profileVM.profile.heightInInches) in")
                        Text("Weight: \(Int(profileVM.profile.weightInPounds)) lbs")
                        Text("BMI: \(String(format: "%.1f", profileVM.profile.bmi))")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                    // Goal
                    if let goal = profileVM.profile.goal {
                        Text("Goal: \(goal)")
                            .font(.body)
                            .padding(.top)
                    }

                    // Log out
                    Button("Log Out") {
                        authVM.logout()
                        profileVM.resetToDefault()
                    }
                    .padding(.top)

                } else {
                    // Log in
                    Button("Log In") {
                        authVM.login { success in
                            if success, let userProfile = authVM.userProfile {
                                profileVM.profile = userProfile
                            }
                        }
                    }
                    .padding()
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Profile")
            .toolbar {
                NavigationLink(destination: EditProfileView()) {
                    Text("Edit")
                }
            }
        }
        .onChange(of: authVM.userProfile) {
            if let newValue = authVM.userProfile {
                profileVM.profile = newValue
            }
        }
    }
}

#Preview {
    Profile()
        .environmentObject(UserProfileViewModel())
        .environmentObject(AuthViewModel())
}
