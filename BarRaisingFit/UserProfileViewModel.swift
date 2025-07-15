//
//  UserProfileViewModel.swift
//  BarRaisingFit
//
//  Created by Otis Young on 7/12/25.
//

import Foundation

class UserProfileViewModel: ObservableObject {
    @Published var profile: UserProfile {
        didSet {
            saveProfile()
        }
    }

    init() {
        if let data = UserDefaults.standard.data(forKey: "UserProfile"),
           let savedProfile = try? JSONDecoder().decode(UserProfile.self, from: data) {
            self.profile = savedProfile
        } else {
            self.profile = UserProfile.default
        }
    }

    func saveProfile() {
        if let data = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(data, forKey: "UserProfile")
        }
    }

    func resetToDefault() {
        self.profile = UserProfile.default
    }

    func updateProfilePicture(with name: String, picture: URL?) {
        profile.name = name
        profile.profilePictureURL = picture
    }
}
