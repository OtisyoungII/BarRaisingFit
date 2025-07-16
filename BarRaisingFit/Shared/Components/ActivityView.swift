//
//  ActivityView.swift
//  BarRaisingFit
//
//  Created by Otis Young on 7/14/25.
//

import SwiftUI

struct ActivityView: View {
    @Binding var hideTabBar: Bool
    @State private var scrollOffset: CGFloat = 0

    // 🔥 Health Data States
    @State private var steps: Double?
    @State private var distance: Double?
    @State private var calories: Double?
    @State private var flightsClimbed: Double?
    @State private var heartRate: Double?

    var body: some View {
        ScrollView {
            // Top offset observer
            GeometryReader { geo in
                Color.clear
                    .preference(key: ScrollOffsetKey.self, value: geo.frame(in: .global).minY)
            }
            .frame(height: 0)

            VStack(spacing: 20) {
                Text("Activity Summary")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)

                // 🔲 Responsive 2‑column layout
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    MetricCard(title: "Steps", value: formatted(self.steps, isCount: true))
                    MetricCard(title: "Distance", value: formatted(self.distance, isMiles: true))
                    MetricCard(title: "Calories", value: formatted(self.calories, suffix: " kcal"))
                    MetricCard(title: "Flights", value: formatted(self.flightsClimbed, isCount: true))
                    MetricCard(title: "Heart Rate", value: formatted(self.heartRate, suffix: " bpm"))
                }
                .padding(.horizontal)

                // 📡 Manual refresh
                Button(action: fetchData) {
                    Label("Refresh", systemImage: "arrow.clockwise")
                        .font(.headline)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.bottom, 20)
            }
        }
        .onPreferenceChange(ScrollOffsetKey.self) { offset in
            withAnimation {
                hideTabBar = offset < -50
            }
        }
        .navigationTitle("Activity")
        .onAppear {
            HealthKitManager.shared.requestAuthorization { success in
                if success {
                    fetchData()
                } else {
                    print("❌ Authorization failed. Skipping data fetch.")
                }
            }
        }
    }

    // 🛠 Data formatting helper
    private func formatted(_ value: Double?, isCount: Bool = false, isMiles: Bool = false, suffix: String = "") -> String {
        guard let v = value else { return "--" }
        if isCount { return "\(Int(v))" }
        if isMiles {
            let miles = v * 0.000621371
            return String(format: "%.2f mi", miles)
        }
        return suffix.isEmpty ? String(format: "%.1f", v) : String(format: "%.0f%@", v, suffix)
    }

    // 🔄 Fetch all metrics
    private func fetchData() {
        HealthKitManager.shared.fetchStepCount { value in
            DispatchQueue.main.async {
                self.steps = value
            }
        }
        HealthKitManager.shared.fetchDistanceWalked { value in
            DispatchQueue.main.async {
                self.distance = value
            }
        }
        HealthKitManager.shared.fetchFlightsClimbed { value in
            DispatchQueue.main.async {
                self.flightsClimbed = value
            }
        }
        HealthKitManager.shared.fetchActiveEnergy { value in
            DispatchQueue.main.async {
                self.calories = value
            }
        }
        HealthKitManager.shared.startHeartRateUpdates { value in
            DispatchQueue.main.async {
                self.heartRate = value
            }
        }
    }
}

struct ActivityView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityView(hideTabBar: .constant(false))
    }
}
