//
//  MetricDashboard.swift
//  BarRaisingFit
//
//  Created by Otis Young on 7/14/25.
//

import SwiftUI
import HealthKit

struct MetricsDashboard: View {
    @Binding var hideTabBar: Bool
    @State private var headerOffset: CGFloat = 0

    @State private var steps = 0.0
    @State private var distance = 0.0
    @State private var flights = 0.0
    @State private var heartRate = 0.0

    var body: some View {
        ScrollView(showsIndicators: false) {
            GeometryReader { geo in
                let minY = geo.frame(in: .global).minY

                Image("Some")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width,
                           height: max(geo.size.height,
                                       geo.size.height - minY))
                    .clipped()
                    .offset(y: minY > 0 ? -minY : 0)
                    .onAppear {
                        headerOffset = minY
                    }
                    .onChange(of: minY) { oldValue, newValue in
                        headerOffset = newValue
                        withAnimation {
                            hideTabBar = newValue < -50
                        }
                    }
            }
            .frame(height: 300)

            VStack(spacing: 20) {
                Spacer().frame(height: 140)

                VStack(spacing: 16) {
                    MetricCard(title: "Steps", value: "\(Int(steps))")
                    MetricCard(title: "Heart Rate", value: "\(Int(heartRate)) bpm")
                    MetricCard(title: "Distance", value: String(format: "%.2f mi", distance * 0.000621371))
                    MetricCard(title: "Flights", value: "\(Int(flights))")
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(radius: 8)
                .offset(y: -min(headerOffset, 0) / 4)
            }
            .padding(.bottom, 60)
        }
        .ignoresSafeArea()
        .onAppear {
            HealthKitManager.shared.requestAuthorization { granted in
                if granted {
                    HealthKitManager.shared.fetchStepCount { v in if let v = v { steps = v } }
                    HealthKitManager.shared.fetchDistanceWalked { v in if let v = v { distance = v } }
                    HealthKitManager.shared.fetchFlightsClimbed { v in if let v = v { flights = v } }
                    HealthKitManager.shared.startHeartRateUpdates { bpm in heartRate = bpm }
                    HealthKitManager.shared.startObservingStepCountUpdates { c in steps = c }
                }
            }
        }
    }
}

#Preview {
    MetricsDashboard(hideTabBar: .constant(false))
        .environmentObject(UserProfileViewModel())
}
#Preview {
    MetricsDashboard(hideTabBar: .constant(false))
}
