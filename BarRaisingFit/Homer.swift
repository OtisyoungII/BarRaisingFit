//
//  Homer.swift
//  BarRaisingFit
//
//  Created by Otis Young on 7/11/25.
//

import SwiftUI
import AudioToolbox
import HealthKit

struct Homer: View {
    @State private var showTimerOptions = false
    @State private var showCustomTimeInput = false
    @State private var customTime = 30
    
    @State private var countdown = 0
    @State private var totalTime = 0
    @State private var timerRunning = false
    @State private var isPaused = false
    @State private var taskID = UUID()
    
    @State private var todaySteps: Double = 0
    
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
                        
                        Text("Today's Steps: \(Int(todaySteps))")
                            .foregroundColor(.white)
                            .font(.headline)
                            .padding(.bottom, 5)
                        
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
                        
                        Spacer(minLength: 40)
                        
                        // Circular Progress Ring
                        if timerRunning {
                            ZStack {
                                Circle()
                                    .stroke(lineWidth: 12)
                                    .opacity(0.2)
                                    .foregroundColor(.white)
                                
                                Circle()
                                    .trim(from: 0, to: CGFloat(progressFraction))
                                    .stroke(style: StrokeStyle(lineWidth: 12, lineCap: .round))
                                    .foregroundColor(.green)
                                    .rotationEffect(.degrees(-90))
                                    .animation(.linear(duration: 0.2), value: countdown)
                                
                                Text("\(countdown) sec")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .bold()
                            }
                            .frame(width: 200, height: 200)
                        }
                        
                        // Pause / Resume / Reset
                        if timerRunning {
                            HStack(spacing: 20) {
                                Button(action: pauseOrResumeTimer) {
                                    Text(isPaused ? "Resume" : "Pause")
                                        .font(.headline)
                                        .padding()
                                        .background(.ultraThinMaterial)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .foregroundColor(.white)
                                }
                                
                                if isPaused {
                                    Button(action: resetTimer) {
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
                                Text("Workouts")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(.ultraThinMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                    .shadow(radius: 3)
                                    .foregroundColor(.white)
                            }
                            NavigationLink(destination: GrindHouseChallenges()) {
                                Text("GrindHouse Challenges")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(.ultraThinMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                    .shadow(radius: 3)
                                    .foregroundColor(.white)
                            }
                            NavigationLink(destination: Leaderboards()) {
                                Text("Leaderboards")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(.ultraThinMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                    .shadow(radius: 3)
                                    .foregroundColor(.white)
                            }
                            NavigationLink(destination: Profile()) {
                                Text("Profile")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(.ultraThinMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                    .shadow(radius: 3)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer(minLength: 40)
                    }
                }
                
                // Timer Options
                if showTimerOptions {
                    VStack(spacing: 15) {
                        Text("Select Duration")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)
                        
                        ForEach([30, 45, 60], id: \.self) { sec in
                            Button("\(sec) Seconds") {
                                startCountdown(sec)
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
            }
            .navigationBarHidden(true)
            .onAppear {
                requestHealthKitPermissions()
                HealthKitManager.shared.fetchStepCount { steps in
                    if let steps = steps {
                        DispatchQueue.main.async {
                            todaySteps = steps
                        }
                    }
                }
            }
            .sheet(isPresented: $showCustomTimeInput) {
                VStack {
                    Text("Custom Duration")
                        .font(.title2)
                        .bold()
                        .padding()
                    
                    Stepper("Time: \(customTime) seconds", value: $customTime, in: 10...600, step: 5)
                        .padding()
                    
                    Button("Start Timer") {
                        startCountdown(customTime)
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
        }
    }
    
    // MARK: - Timer Functions
    
    func startCountdown(_ time: Int) {
        countdown = time
        totalTime = time
        timerRunning = true
        isPaused = false
        taskID = UUID()
        
        Task {
            let thisID = taskID
            while countdown > 0 && taskID == thisID {
                if !isPaused {
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                    countdown -= 1
                } else {
                    try? await Task.sleep(nanoseconds: 200_000_000)
                }
            }
            
            if countdown <= 0 && taskID == thisID {
                timerRunning = false
                isPaused = false
                playSystemSound()
            }
        }
    }
    
    func pauseOrResumeTimer() {
        isPaused.toggle()
    }
    
    func resetTimer() {
        taskID = UUID()
        countdown = 0
        timerRunning = false
        isPaused = false
    }
    
    func playSystemSound() {
        AudioServicesPlaySystemSound(SystemSoundID(1005)) // You can try others like 1007, 1012, etc.
    }
    
    var progressFraction: Double {
        guard totalTime > 0 else { return 0 }
        return Double(totalTime - countdown) / Double(totalTime)
    }
    
    func requestHealthKitPermissions() {
        HealthKitManager.shared.requestAuthorization { success in
            if success {
                print("✅ HealthKit permission granted.")
            } else {
                print("❌ HealthKit permission denied.")
            }
        }
    }
}

// 👇 Required for preview, assuming your app uses this environment object
#Preview {
    Homer()
        .environmentObject(UserProfileViewModel())
}



