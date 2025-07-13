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
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Title
                    Text("👤 Profile")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    // Basic Info
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Name: \(profileVM.profile.name)")
                            Text("Age: \(profileVM.profile.age)")
                            if let gender = profileVM.profile.gender {
                                Text("Gender: \(gender)")
                            }
                        }
                        Spacer()
                    }
                    .font(.headline)

                    Divider()

                    // Physical Stats
                    VStack(alignment: .leading, spacing: 10) {
                        Text("📏 Height: \(String(format: "%.1f", profileVM.profile.heightInInches)) in")
                        Text("⚖️ Weight: \(String(format: "%.1f", profileVM.profile.weightInPounds)) lbs")
                        Text("📊 BMI: \(String(format: "%.1f", profileVM.profile.bmi))")
                    }

                    Divider()

                    // Goal and Membership
                    VStack(alignment: .leading, spacing: 10) {
                        if let goal = profileVM.profile.goal {
                            Text("🎯 Goal: \(goal)")
                        }
                        Text("📅 Joined: \(profileVM.profile.dateJoined, formatter: dateFormatter)")
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
        .environmentObject(UserProfileViewModel())
}
