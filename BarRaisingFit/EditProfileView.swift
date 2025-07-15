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

    var body: some View {
        Form {
            Section(header: Text("Basic Info")) {
                TextField("Name", text: $profileVM.profile.name)
                TextField("Age", value: $profileVM.profile.age, formatter: NumberFormatter())
                Picker("Gender", selection: Binding(
                    get: { profileVM.profile.gender ?? "" },
                    set: { profileVM.profile.gender = $0 }
                )) {
                    Text("Not Set").tag("")
                    Text("Male").tag("Male")
                    Text("Female").tag("Female")
                    Text("Other").tag("Other")
                }
            }

            Section(header: Text("Body Metrics")) {
                Stepper(value: $profileVM.profile.heightInFeet, in: 0...8) {
                    Text("Height: \(profileVM.profile.heightInFeet) ft \(profileVM.profile.heightInInches) in")
                }
                Stepper(value: $profileVM.profile.heightInInches, in: 0...11) {
                    EmptyView()
                }
                TextField("Weight (lbs)", value: $profileVM.profile.weightInPounds, formatter: NumberFormatter())
                    .keyboardType(.decimalPad)
            }

            Section(header: Text("Goal")) {
                TextField("Fitness Goal", text: Binding(
                    get: { profileVM.profile.goal ?? "" },
                    set: { profileVM.profile.goal = $0 }
                ))
            }

            Section {
                Button("Save & Close") {
                    profileVM.saveProfile()
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .navigationTitle("Edit Profile")
    }
}
#Preview {
    EditProfileView()
}
