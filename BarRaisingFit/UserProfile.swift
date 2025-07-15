//
//  UserProfile.swift
//  BarRaisingFit
//
//  Created by Otis Young on 7/12/25.
//

import Foundation

struct UserProfile: Codable, Equatable {
    var name: String
    var age: Int
    var heightInFeet: Int
    var heightInInches: Int
    var weightInPounds: Double
    var gender: String?
    var dateJoined: Date
    var goal: String?
    var profilePictureURL: URL?

    var totalHeightInInches: Double {
        Double(heightInFeet) * 12 + Double(heightInInches)
    }

    var bmi: Double {
        (weightInPounds / (totalHeightInInches * totalHeightInInches)) * 703
    }

    static var `default`: UserProfile {
        return UserProfile(
            name: "Jane Doe",
            age: 28,
            heightInFeet: 5,
            heightInInches: 5,
            weightInPounds: 145.0,
            gender: "Female",
            dateJoined: Date(),
            goal: "Lose fat & build muscle",
            profilePictureURL: nil
        )
    }
}
