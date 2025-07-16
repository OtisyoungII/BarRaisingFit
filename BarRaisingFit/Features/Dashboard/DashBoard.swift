//
//  DashBoard.swift
//  BarRaisingFit
//
//  Created by Otis Young on 7/14/25.
//

import SwiftUI

struct Dashboard: View {
    @State private var steps: Double = 0
    @State private var distance: Double = 0
    @State private var flights: Double = 0
    @State private var heartRate: Double = 0

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                HStack(spacing: 15) {
                    MetricCard(title: "Steps", value: "\(Int(steps))")
                    MetricCard(title: "Distance (m)", value: String(format: "%.2f", distance))
                }
                .padding(.horizontal)

                HStack(spacing: 15) {
                    MetricCard(title: "Flights Climbed", value: "\(Int(flights))")
                    MetricCard(title: "Heart Rate", value: heartRate > 0 ? String(format: "%.0f bpm", heartRate) : "--")
                }
                .padding(.horizontal)

                Spacer()
            }
            .navigationTitle("Dashboard")
            .onAppear {
                requestHealthData()
            }
        }
    }

    private func requestHealthData() {
        
        HealthKitManager.shared.requestAuthorization { success in
            guard success else { return }
            
            HealthKitManager.shared.fetchStepCount { value in
                DispatchQueue.main.async {
                    steps = value ?? 0
                    StepDataManager.shared.addOrUpdateStepCount(steps, on: Date()) // ✅ Fixed
                }
                
            }
            
            HealthKitManager.shared.fetchDistanceWalked { value in
                DispatchQueue.main.async { distance = value ?? 0 }
            }
            
            HealthKitManager.shared.fetchFlightsClimbed { value in
                DispatchQueue.main.async { flights = value ?? 0 }
            }
            
            HealthKitManager.shared.startHeartRateUpdates { bpm in
                heartRate = bpm
            }
            
            HealthKitManager.shared.startObservingStepCountUpdates { newSteps in
                steps = newSteps
                StepDataManager.shared.addOrUpdateStepCount(newSteps, on: Date()) // ✅ Fixed
            }
        }
            HealthKitManager.shared.fetchDistanceWalked { value in
                DispatchQueue.main.async { distance = value ?? 0 }
            }

            HealthKitManager.shared.fetchFlightsClimbed { value in
                DispatchQueue.main.async { flights = value ?? 0 }
            }

            HealthKitManager.shared.startHeartRateUpdates { bpm in
                heartRate = bpm
            }

            HealthKitManager.shared.startObservingStepCountUpdates { newSteps in
                steps = newSteps
                StepDataManager.shared.addOrUpdateStepCount(newSteps, on: Date())
            }
        }
    }


#Preview {
    Dashboard()
}
