//
//  Homer.swift
//  BarRaisingFit
//
//  Created by Otis Young on 7/11/25.
//

import SwiftUI
import HealthKit

struct Homer: View {
    @State private var showTimerOptions = false
    @State private var showCustomTimeInput = false
    @State private var customTime = 30

    @State private var todaySteps: Double = 0
    @State private var distanceWalked: Double = 0
    @State private var flightsClimbed: Double = 0
    @State private var currentHeartRate: Double = 0

    @StateObject private var timer = TimerManager()

    var body: some View {
        NavigationView {
            ZStack {
                Color("Teal1")
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        Text("BarRaisingFitnessApp")
                            .font(.largeTitle)
                            .bold()
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .foregroundColor(.white)
                            .padding(.top)

                        Image("Some")
                            .resizable()
                            .frame(width: 200, height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 20))

                        // Metric Cards
                        HStack(spacing: 12) {
                            MetricCard(title: "Steps", value: "\(Int(todaySteps))")
                            MetricCard(title: "Distance", value: String(format: "%.2f mi", distanceWalked * 0.000621371))
                            MetricCard(title: "Flights", value: "\(Int(flightsClimbed))")
                            MetricCard(title: "Heart Rate", value: "\(Int(currentHeartRate)) bpm")
                        }
                        .padding(.horizontal)

                        Button {
                            showTimerOptions.toggle()
                        } label: {
                            Text("Start Workout")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .shadow(radius: 4)
                        }
                        .padding(.horizontal)
                        .foregroundColor(.white)

                        // Timer Ring
                        if timer.timerRunning {
                            ZStack {
                                Circle()
                                    .stroke(lineWidth: 12)
                                    .opacity(0.2)
                                    .foregroundColor(.white)

                                Circle()
                                    .trim(from: 0, to: CGFloat(timer.progressFraction))
                                    .stroke(style: StrokeStyle(lineWidth: 12, lineCap: .round))
                                    .foregroundColor(.green)
                                    .rotationEffect(.degrees(-90))
                                    .animation(.linear(duration: 0.2), value: timer.countdown)

                                Text("\(timer.countdown) sec")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .bold()
                            }
                            .frame(width: 200, height: 200)
                        }

                        if timer.timerRunning {
                            HStack(spacing: 20) {
                                Button(action: timer.pauseOrResumeTimer) {
                                    Text(timer.isPaused ? "Resume" : "Pause")
                                        .font(.headline)
                                        .padding()
                                        .background(.ultraThinMaterial)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .foregroundColor(.white)
                                }

                                if timer.isPaused {
                                    Button(action: timer.resetTimer) {
                                        Text("Reset")
                                            .font(.headline)
                                            .padding()
                                            .background(.ultraThinMaterial)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                        }

                        Spacer(minLength: 30)

                        // Navigation Buttons
                        VStack(spacing: 10) {
                            NavigationLink(destination: Workouts()) {
                                navButtonLabel("Workouts")
                            }
                            NavigationLink(destination: GrindHouseChallenges()) {
                                navButtonLabel("GrindHouse Challenges")
                            }
                            NavigationLink(destination: Leaderboards()) {
                                navButtonLabel("Leaderboards")
                            }
                            NavigationLink(destination: Profile()) {
                                navButtonLabel("Profile")
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                // Timer Options Modal
                if showTimerOptions {
                    timerOptionsSheet
                }
            }
            .navigationBarHidden(true)
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
                    } else {
                        print("❌ HealthKit permission denied.")
                    }
                }
            }
            .sheet(isPresented: $showCustomTimeInput) {
                customTimeSheet
            }
        }
    }

    // MARK: - Helpers

    var timerOptionsSheet: some View {
        VStack(spacing: 15) {
            Text("Select Duration")
                .font(.title2)
                .bold()
                .foregroundColor(.white)

            ForEach([30, 45, 60], id: \.self) { sec in
                Button("\(sec) Seconds") {
                    timer.startCountdown(sec)
                    showTimerOptions = false
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .foregroundColor(.white)
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
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .padding(30)
    }

    var customTimeSheet: some View {
        VStack {
            Text("Custom Duration")
                .font(.title2)
                .bold()
                .padding()

            Stepper("Time: \(customTime) seconds", value: $customTime, in: 10...600, step: 5)
                .padding()

            Button("Start Timer") {
                timer.startCountdown(customTime)
                showTimerOptions = false
                showCustomTimeInput = false
            }
            .padding()
            .background(Color.blue.opacity(0.8))
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Button("Cancel") {
                showCustomTimeInput = false
            }
            .foregroundColor(.red)
        }
        .padding()
    }

    func navButtonLabel(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .shadow(radius: 3)
            .foregroundColor(.white)
    }
}

#Preview {
    Homer()
        .environmentObject(UserProfileViewModel())
}



