//
//  StepRecord.swift
//  BarRaisingFit
//
//  Created by Otis Young on 7/16/25.
//

import Foundation

struct StepRecord: Identifiable, Codable {
    let id: UUID
    let date: Date
    let stepCount: Double
    
    init(id: UUID = UUID(), date: Date, stepCount: Double) {
        self.id = id
        self.date = date
        self.stepCount = stepCount
    }
}
