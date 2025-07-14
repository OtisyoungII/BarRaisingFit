//
//  ProfileView.swift
//  BarRaisingFit
//
//  Created by Otis Young on 7/14/25.
//

import SwiftUI

struct ProfileView: View {
    @Binding var hideTabBar: Bool
    @EnvironmentObject var profileVM: UserProfileViewModel

    @State private var name: String = ""
    @State private var age: String = ""
    @State private var height: String = ""
    @State private var weight: String = ""
    @State private var gender: String = ""
    @State private var goal: String = ""

    var body: some View {
        ScrollView {
            VStack {
                Form {
                    Section(header: Text("Personal Info")) {
                        TextField("Name", text: $name)
                        TextField("Age", text: $age)
                            .keyboardType(.numberPad)
                        TextField("Height (inches)", text: $height)
                            .keyboardType(.decimalPad)
                        TextField("Weight (lbs)", text: $weight)
                            .keyboardType(.decimalPad)
                        TextField("Gender", text: $gender)
                    }

                    Section(header: Text("Goals")) {
                        TextField("Goal", text: $goal)
                    }

                    Section(header: Text("Statistics")) {
                        Text("BMI: \(profileVM.profile.bmi, specifier: "%.1f")")
                        Text("Date Joined: \(profileVM.profile.dateJoined, formatter: dateFormatter)")
                    }

                    Section {
                        Button("Save") {
                            saveProfile()
                        }
                        Button("Reset to Default") {
                            profileVM.resetToDefault()
                            loadProfile()
                        }
                        .foregroundColor(.red)
                    }
                }
            }
        }
        .onAppear {
            loadProfile()
        }
        .onChange(of: hideTabBar) { oldValue, newValue in
            print("Tab bar visibility changed from \(oldValue) to \(newValue)")
        }
        .navigationTitle("Profile")
    }

    private func loadProfile() {
        let p = profileVM.profile
        name = p.name
        age = String(p.age)
        height = String(format: "%.1f", p.heightInInches)
        weight = String(format: "%.1f", p.weightInPounds)
        gender = p.gender ?? ""
        goal = p.goal ?? ""
    }

    private func saveProfile() {
        profileVM.profile.name = name
        profileVM.profile.age = Int(age) ?? profileVM.profile.age
        profileVM.profile.heightInInches = Double(height) ?? profileVM.profile.heightInInches
        profileVM.profile.weightInPounds = Double(weight) ?? profileVM.profile.weightInPounds
        profileVM.profile.gender = gender.isEmpty ? nil : gender
        profileVM.profile.goal = goal.isEmpty ? nil : goal
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()

#Preview {
    ProfileView(hideTabBar: .constant(false))
        .environmentObject(UserProfileViewModel())
}
