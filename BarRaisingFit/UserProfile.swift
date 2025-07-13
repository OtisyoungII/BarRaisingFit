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
    var heightInInches: Double
    var weightInPounds: Double
    var gender: String?
    var dateJoined: Date
    var goal: String?

    var bmi: Double {
        (weightInPounds / (heightInInches * heightInInches)) * 703
    }
}
