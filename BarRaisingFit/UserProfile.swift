//
//  UserProfile.swift
//  BarRaisingFit
//
//  Created by Otis Young on 7/12/25.
//

import Foundation

struct UserProfile {
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
}
