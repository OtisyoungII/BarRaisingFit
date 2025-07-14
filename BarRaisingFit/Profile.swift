//
//  Profile.swift
//  BarRaisingFit
//
//  Created by Otis Young on 7/12/25.
//

import SwiftUI

struct Profile: View {
    @EnvironmentObject var profileVM: UserProfileViewModel

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let url = profileVM.profile.profilePictureURL {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 120, height: 120)
                        case .success(let image):
                            image
                                .resizable()
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

                Text(profileVM.profile.name)
                    .font(.title)
                    .bold()

                HStack(spacing: 20) {
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

                VStack(spacing: 10) {
                    Text("Height: \(String(format: "%.1f", profileVM.profile.heightInInches / 12)) ft")
                    Text("Weight: \(Int(profileVM.profile.weightInPounds)) lbs")
                    Text("BMI: \(String(format: "%.1f", profileVM.profile.bmi))")
                }
                .font(.subheadline)
                .foregroundColor(.secondary)

                if let goal = profileVM.profile.goal {
                    Text("Goal: \(goal)")
                        .font(.body)
                        .padding(.top)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    Profile()
        .environmentObject(UserProfileViewModel())
}        

