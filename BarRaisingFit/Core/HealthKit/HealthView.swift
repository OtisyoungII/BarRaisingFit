//
//  HealthView.swift
//  BarRaisingFit
//
//  Created by Otis Young on 7/14/25.
//

import SwiftUI
import Combine

struct HealthView: View {
    @State private var stepCount: Double = 0
    @State private var distance: Double = 0
    @State private var flightsClimbed: Double = 0
    @State private var heartRate: Double = 0
    @State private var permissionGranted = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if permissionGranted {
                    VStack(spacing: 16) {
                        MetricCard(title: "Steps", value: "\(Int(stepCount))")
                        MetricCard(title: "Distance (m)", value: String(format: "%.1f", distance))
                        MetricCard(title: "Flights Climbed", value: "\(Int(flightsClimbed))")
                        MetricCard(title: "Heart Rate (BPM)", value: String(format: "%.0f", heartRate))

                        NavigationLink(destination: StepHistoryView()) {
                            Text("View Step History")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(10)
                        }
                        .padding(.top)
                    }
                    .padding()
                } else {
                    Text("Requesting HealthKit permission...")
                        .onAppear {
                            HealthKitManager.shared.requestAuthorization { granted in
                                permissionGranted = granted
                                if granted {
                                    fetchAllMetrics()
                                    startHeartRateUpdates()
                                    startStepCountObserver()
                                    StepDataManager.shared.syncWithHealthKit()
                                }
                            }
                        }
                        .padding()
                }
                Spacer()
            }
            .navigationTitle("Health Stats")
        }
    }

    private func fetchAllMetrics() {
        HealthKitManager.shared.fetchStepCount { steps in
            if let steps = steps {
                stepCount = steps
            }
        }
        HealthKitManager.shared.fetchDistanceWalked { dist in
            if let dist = dist {
                distance = dist
            }
        }
        HealthKitManager.shared.fetchFlightsClimbed { flights in
            if let flights = flights {
                flightsClimbed = flights
            }
        }
    }

    private func startStepCountObserver() {
        HealthKitManager.shared.startObservingStepCountUpdates { steps in
            stepCount = steps
        }
    }

    private func startHeartRateUpdates() {
        HealthKitManager.shared.startHeartRateUpdates { bpm in
            heartRate = bpm
        }
    }
}

#Preview {
    HealthView()
}
