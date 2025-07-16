//
//  EditProfileView.swift
//  BarRaisingFit
//
//  Created by Otis Young on 7/14/25.
//

import SwiftUI

struct EditProfileView: View {
    @EnvironmentObject var profileVM: UserProfileViewModel
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var keyboard = KeyboardResponder()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                GroupBox(label: Text("Basic Info")) {
                    VStack(alignment: .leading, spacing: 10) {
                        TextField("Name", text: $profileVM.profile.name)
                        TextField("Age", value: $profileVM.profile.age, formatter: NumberFormatter())
                            .keyboardType(.numberPad)

                        Picker("Gender", selection: Binding(
                            get: { profileVM.profile.gender ?? "" },
                            set: { profileVM.profile.gender = $0 }
                        )) {
                            Text("Not Set").tag("")
                            Text("Male").tag("Male")
                            Text("Female").tag("Female")
                            Text("Other").tag("Other")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                }

                GroupBox(label: Text("Body Metrics")) {
                    VStack(alignment: .leading, spacing: 10) {
                        Stepper(value: $profileVM.profile.heightInFeet, in: 0...8) {
                            Text("Height: \(profileVM.profile.heightInFeet) ft \(profileVM.profile.heightInInches) in")
                        }
                        Stepper(value: $profileVM.profile.heightInInches, in: 0...11) {
                            EmptyView()
                        }

                        TextField("Weight (lbs)", value: $profileVM.profile.weightInPounds, formatter: NumberFormatter())
                            .keyboardType(.decimalPad)
                    }
                }

                GroupBox(label: Text("Goal")) {
                    TextField("Fitness Goal", text: Binding(
                        get: { profileVM.profile.goal ?? "" },
                        set: { profileVM.profile.goal = $0 }
                    ))
                }

                Button("Save & Close") {
                    profileVM.saveProfile()
                    presentationMode.wrappedValue.dismiss()
                }
                .buttonStyle(.borderedProminent)
                .padding(.top)
            }
            .padding()
        }
        .padding(.bottom, keyboard.isKeyboardVisible ? 300 : 0) // Push up when keyboard is visible
        .animation(.easeOut(duration: 0.25), value: keyboard.isKeyboardVisible)
        .navigationTitle("Edit Profile")
    }
}
#Preview {
    EditProfileView()
}
