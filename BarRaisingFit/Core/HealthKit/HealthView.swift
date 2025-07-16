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
    @State private var isHealthKitAuthorized = false
    
    
    
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
                                print("🔑 HealthKit permission callback. Granted: \(granted)")
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
            DispatchQueue.main.async {
                stepCount = steps ?? 0
            }
        }
        HealthKitManager.shared.fetchDistanceWalked { dist in
            DispatchQueue.main.async {
                distance = dist ?? 0
            }
        }
        HealthKitManager.shared.fetchFlightsClimbed { flights in
            DispatchQueue.main.async {
                flightsClimbed = flights ?? 0
            }
        }
    }
    
    private func startStepCountObserver() {
        HealthKitManager.shared.startObservingStepCountUpdates { steps in
            DispatchQueue.main.async {
                stepCount = steps
            }
        }
    }
    
    private func startHeartRateUpdates() {
        HealthKitManager.shared.startHeartRateUpdates { bpm in
            DispatchQueue.main.async {
                heartRate = bpm
            }
        }
    }
}
#Preview {
    HealthView()
}
