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

    init() {
    self.profile = UserProfile(
    name: "Jane Doe",
    age: 28,
    heightInInches: 65.0, // 5'5"
    weightInPounds: 145.0,
    gender: "Female",
    dateJoined: Date(timeIntervalSinceNow: -86400 * 90),
    goal: "Lose fat & build muscle"
    )
    }
    }


#Preview {
    Profile()
        .environmentObject(UserProfileViewModel())
}
