//
//  Workouts.swift
//  BarRaisingFit
//
//  Created by Otis Young on 7/12/25.
//

import SwiftUI

struct Workouts: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Workout Screen")
                    .font(.largeTitle)
                    .padding()
                // Add your workout UI here
            }
            .navigationTitle("Workout")
        }
    }
}

#Preview {
    Workouts()
}
