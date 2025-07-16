//
//  Homer.swift
//  BarRaisingFit
//
//  Created by Otis Young on 7/11/25.
//

import SwiftUI
import HealthKit

enum Tab {
    case metrics, activity, profile, settings, history
}

struct Homer: View {
    @EnvironmentObject var appState: AppState

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
    @State private var hideTabBar: Bool = false

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .metrics:
                    metricsTabView
                case .activity:
                    ActivityView(hideTabBar: $hideTabBar)
                case .profile:
                    Profile()
                case .settings:
                    SettingsView(hideTabBar: $hideTabBar)
                case .history:
                    StepHistoryView()
                }
            }
            .onPreferenceChange(ScrollOffsetKey.self) { newOffset in
                withAnimation {
                    if timer.timerRunning {
                        hideTabBar = false
                    } else {
                        hideTabBar = newOffset < -50
                    }
                    offset = newOffset
                }
            }
            .onAppear {
                handleHealthKitFetch()
            }

            if !hideTabBar {
                GlassEffectTabBar(selectedTab: $selectedTab)
                    .padding(.horizontal)
                    .padding(.bottom, 12)
            }
        }
        .edgesIgnoringSafeArea(.top)
        .sheet(isPresented: $showCustomTimeInput) {
            customTimeSheet
        }

        if showTimerOptions {
            timerOptionsSheet
        }
    }

    private var metricsTabView: some View {
        ScrollViewReader { proxy in
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

                    metricsSection

                    Button {
                        withAnimation {
                            showTimerOptions.toggle()
                        }
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
                        VStack(spacing: 16) {
                            TimerCardView(timer: timer)
                                .frame(width: 200, height: 200)
                            TimerControlButtonsView(timer: timer)
                        }
                        .id("TIMER_SECTION")
                    }

                    Spacer(minLength: 30)
                }
                .padding()
            }
            .onChange(of: selectedTab) {
                if selectedTab == .history {
                    StepDataManager.shared.syncWithHealthKit()
                    print("🔄 Syncing step history on tab change")
                }
            }
        }
    }

    private var metricsSection: some View {
        VStack(spacing: 16) {
            MetricCard(title: "Steps", value: "\(Int(todaySteps))")
            MetricCard(title: "Heart Rate", value: "\(Int(currentHeartRate)) bpm")
            MetricCard(title: "Distance", value: String(format: "%.2f mi", distanceWalked * 0.000621371))
            MetricCard(title: "Flights", value: "\(Int(flightsClimbed))")
        }
    }

    private var timerOptionsSheet: some View {
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

    private var customTimeSheet: some View {
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

    private func handleHealthKitFetch() {
        HealthKitManager.shared.requestAuthorization { success in
        guard success else { return }

        if appState.mode != .guest {
            guard let startDate = Calendar.current.date(byAdding: .day, value: -30, to: Date()) else { return }
            
            HealthKitManager.shared.fetchHistoricalSteps(startDate: startDate) { records in
                for record in records {
                    StepDataManager.shared.addOrUpdateStepCount(record.stepCount, on: record.date)
                }
                print("✅ Historical steps synced and saved")
            }
        }
        // ... (rest unchanged)
            }

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

struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
#Preview {
    Homer()
        .environmentObject(UserProfileViewModel())
        .environmentObject(AuthViewModel())
}
