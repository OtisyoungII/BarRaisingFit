//
//  Homer.swift
//  BarRaisingFit
//
//  Created by Otis Young on 7/11/25.
//

import SwiftUI
import HealthKit

enum Tab: String {
    case metrics, activity, profile, settings
}

struct Homer: View {
    @State private var showTimerOptions = false
    @State private var showCustomTimeInput = false
    @State private var customTime = 30

    @State private var todaySteps: Double = 0
    @State private var distanceWalked: Double = 0
    @State private var flightsClimbed: Double = 0
    @State private var currentHeartRate: Double = 0

    @StateObject private var timer = TimerManager()
    @State private var offset: CGFloat = 0
    @State private var selectedTab: Tab = .metrics

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                GeometryReader { geo in
                    Color.clear
                        .preference(key: ScrollOffsetKey.self, value: geo.frame(in: .global).minY)
                }
                .frame(height: 0)

                HeroHeader()
                    .frame(height: 250)

                VStack(spacing: 20) {
                    Text("BarRaisingFitnessApp")
                        .font(.largeTitle)
                        .bold()

                    switch selectedTab {
                    case .metrics:
                        metricsSection
                    case .activity:
                        activitySection
                    case .profile:
                        profileSection
                    case .settings:
                        settingsSection
                    }

                    Button {
                        showTimerOptions.toggle()
                    } label: {
                        Text("Start Workout")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green.opacity(0.9))
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal)

                    if timer.timerRunning {
                        ZStack {
                            Circle()
                                .stroke(lineWidth: 12)
                                .opacity(0.2)
                                .foregroundColor(.gray)

                            Circle()
                                .trim(from: 0, to: CGFloat(timer.progressFraction))
                                .stroke(style: StrokeStyle(lineWidth: 12, lineCap: .round))
                                .foregroundColor(.green)
                                .rotationEffect(.degrees(-90))
                                .animation(.linear(duration: 0.2), value: timer.countdown)

                            Text("\(timer.countdown) sec")
                                .font(.title2)
                                .bold()
                        }
                        .frame(width: 200, height: 200)

                        HStack(spacing: 20) {
                            Button(action: timer.pauseOrResumeTimer) {
                                Text(timer.isPaused ? "Resume" : "Pause")
                                    .font(.headline)
                                    .padding()
                                    .background(Color.orange)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .foregroundColor(.white)
                            }

                            if timer.isPaused {
                                Button(action: timer.resetTimer) {
                                    Text("Reset")
                                        .font(.headline)
                                        .padding()
                                        .background(Color.red)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    }

                    Spacer(minLength: 30)
                }
                .padding()
            }
            .onPreferenceChange(ScrollOffsetKey.self) { newOffset in
                offset = newOffset
            }
            .onAppear {
                HealthKitManager.shared.requestAuthorization { success in
                    if success {
                        HealthKitManager.shared.fetchStepCount { steps in
                            DispatchQueue.main.async {
                                todaySteps = steps ?? 0
                            }
                        }

                        HealthKitManager.shared.startObservingStepCountUpdates { updatedSteps in
                            todaySteps = updatedSteps
                        }

                        HealthKitManager.shared.fetchDistanceWalked { distance in
                            DispatchQueue.main.async {
                                distanceWalked = distance ?? 0
                            }
                        }

                        HealthKitManager.shared.fetchFlightsClimbed { flights in
                            DispatchQueue.main.async {
                                flightsClimbed = flights ?? 0
                            }
                        }

                        HealthKitManager.shared.startHeartRateUpdates { bpm in
                            currentHeartRate = bpm
                        }
                    }
                }
            }

            GlassEffectTabBar(selectedTab: $selectedTab)
                .padding(.horizontal)
        }
        .edgesIgnoringSafeArea(.top)
        .sheet(isPresented: $showCustomTimeInput) {
            customTimeSheet
        }

        if showTimerOptions {
            timerOptionsSheet
        }
    }

    // MARK: - Tab Sections

    var metricsSection: some View {
        VStack(spacing: 16) {
            MetricCard(title: "Steps", value: "\(Int(todaySteps))")
            MetricCard(title: "Heart Rate", value: "\(Int(currentHeartRate)) bpm")
            MetricCard(title: "Distance", value: String(format: "%.2f mi", distanceWalked * 0.000621371))
            MetricCard(title: "Flights", value: "\(Int(flightsClimbed))")
        }
    }

    var activitySection: some View {
        Text("Activity View Coming Soon")
            .font(.title2)
    }

    var profileSection: some View {
        Text("Profile View Coming Soon")
            .font(.title2)
    }

    var settingsSection: some View {
        Text("Settings View Coming Soon")
            .font(.title2)
    }

    // MARK: - Timer Sheets

    var timerOptionsSheet: some View {
        VStack(spacing: 15) {
            Text("Select Duration")
                .font(.title2)
                .bold()

            ForEach([30, 45, 60], id: \.self) { sec in
                Button("\(sec) Seconds") {
                    timer.startCountdown(sec)
                    showTimerOptions = false
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            Button("Custom Time...") {
                showCustomTimeInput = true
            }
            .foregroundColor(.yellow)

            Button("Cancel") {
                showTimerOptions = false
            }
            .foregroundColor(.red)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .padding(30)
    }

    var customTimeSheet: some View {
        VStack(spacing: 20) {
            Text("Custom Duration")
                .font(.title2)
                .bold()

            Stepper("Time: \(customTime) seconds", value: $customTime, in: 10...600, step: 5)
                .padding()

            Button("Start Timer") {
                timer.startCountdown(customTime)
                showTimerOptions = false
                showCustomTimeInput = false
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Button("Cancel") {
                showCustomTimeInput = false
            }
            .foregroundColor(.red)
        }
        .padding()
    }
}

// MARK: - Hero Header

struct HeroHeader: View {
    var body: some View {
        Image("Some")
            .resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity)
            .clipped()
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [Color.black.opacity(0.3), .clear]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
    }
}

// MARK: - Scroll Offset Key

struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Preview

#Preview {
    Homer()
        .environmentObject(UserProfileViewModel())
}
