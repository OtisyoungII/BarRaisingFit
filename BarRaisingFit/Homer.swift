//
//  Homer.swift
//  BarRaisingFit
//
//  Created by Otis Young on 7/11/25.
//

import SwiftUI
import AVFoundation

struct Homer: View {
    @State private var showTimerOptions = false
    @State private var countdown = 0
    @State private var timerRunning = false
    @State private var isPaused = false
    @State private var taskID = UUID()
    @State private var player: AVAudioPlayer?

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
                            .foregroundColor(.white)
                            .padding(.top)

                        Image("Some")
                            .resizable()
                            .frame(width: 200, height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 20))

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

                        if timerRunning {
                            VStack(spacing: 10) {
                                Text("Time: \(countdown) sec")
                                    .font(.title)
                                    .foregroundColor(.white)

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
                            .padding(.horizontal)
                        }

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
        }
    }

    // MARK: - Timer Logic with Swift Concurrency

    func startCountdown(_ time: Int) {
        countdown = time
        timerRunning = true
        isPaused = false
        taskID = UUID()

        configureAudioSession()

        Task {
            let currentID = taskID
            while countdown > 0 && taskID == currentID {
                if !isPaused {
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                    countdown -= 1
                } else {
                    try? await Task.sleep(nanoseconds: 200_000_000) // Check every 0.2s
                }
            }

            if countdown <= 0 && taskID == currentID {
                timerRunning = false
                isPaused = false
                playAlarm()
            }
        }
    }

    func pauseOrResumeTimer() {
        isPaused.toggle()
    }

    func resetTimer() {
        taskID = UUID() // Cancels the old task
        countdown = 0
        timerRunning = false
        isPaused = false
    }

    func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session setup failed: \(error)")
        }
    }

    func playAlarm() {
        guard let url = Bundle.main.url(forResource: "alarm", withExtension: "mp3") else { return }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch {
            print("Error playing alarm: \(error)")
        }
    }
}
#Preview {
    Homer()
        .environmentObject(UserProfileViewModel())
}



