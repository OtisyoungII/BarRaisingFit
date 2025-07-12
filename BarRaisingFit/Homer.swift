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
    @State private var selectedTime: Int? = nil
    @State private var countdown = 0
    @State private var timerRunning = false
    @State private var timer: Timer?
    @State private var player: AVAudioPlayer?
    @State private var isPaused = false
    @State private var pausedTime: Int = 0

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 20) {
                // Title
                Text("BarRaisingFitnessApp")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.top)

                // Image
                Image("Some")
                    .resizable()
                    .frame(width: 200, height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                // Start Workout Button
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

                // Countdown Timer Display with Pause/Resume and Reset
                if timerRunning {
                    VStack(spacing: 10) {
                        Text("Time: \(countdown) sec")
                            .font(.title)
                            .foregroundColor(.white)

                        HStack(spacing: 20) {
                            Button(action: {
                                pauseOrResumeTimer()
                            }) {
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
                }

                Spacer()

                // Navigation Buttons
                VStack(spacing: 10) {
                    ForEach(["Workouts", "Challenges", "Leaderboard", "Profile"], id: \.self) { label in
                        Button {
                            print("\(label) tapped")
                        } label: {
                            Text(label)
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .shadow(radius: 3)
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.horizontal)
            }

            // Timer Options Pop-Up
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
    }

    // Start countdown timer
    func startCountdown(_ time: Int) {
        countdown = time
        timerRunning = true
        isPaused = false
        timer?.invalidate()

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            countdown -= 1
            if countdown <= 0 {
                timer?.invalidate()
                timerRunning = false
                isPaused = false
                playAlarm()
            }
        }
    }

    // Pause or resume timer
    func pauseOrResumeTimer() {
        if isPaused {
            startCountdown(countdown)
            isPaused = false
        } else {
            timer?.invalidate()
            isPaused = true
        }
    }

    // Reset timer
    func resetTimer() {
        timer?.invalidate()
        timerRunning = false
        isPaused = false
        countdown = 0
    }

    // Play sound when countdown ends
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
}

#Preview {
    Homer()
}
