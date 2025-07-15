//
//  UserProfileViewModel.swift
//  BarRaisingFit
//
//  Created by Otis Young on 7/12/25.
//

import Foundation
import SwiftUI

class UserProfileViewModel: ObservableObject {
    @Published var profile: UserProfile
    init(authName: String = "Jane Doe", profilePictureURL: URL? = nil) {
        self.profile = UserProfile(
            name: authName,
            age: 28,
            heightInFeet: 5,
            heightInInches: 5,
            weightInPounds: 145.0,
            gender: "Female",
            dateJoined: Date(timeIntervalSinceNow: -86400 * 90),
            goal: "Lose fat & build muscle",
            profilePictureURL: profilePictureURL)
    }
    func updateProfilePicture(with name: String, picture: URL?) {
        profile.name = name
        profile.profilePictureURL = picture
    }
    func resetToDefault() {
        profile = UserProfile(
            name: "Jane Doe",
            age: 28,
            heightInFeet: 5,
            heightInInches: 5,
            weightInPounds: 145.0,
            gender: "Female",
            dateJoined: Date(timeIntervalSinceNow: -86400 * 90),
            goal: "Lose fat & build muscle",
            profilePictureURL: nil
        )
    }
}
