//
//  TimeView.swift
//  BarRaisingFit
//
//  Created by Otis Young on 7/14/25.
//

import SwiftUI

struct TimerView: View {
    @StateObject private var timerManager = TimerManager()
    @State private var inputTime = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("Countdown Timer")
                    .font(.largeTitle)
                    .bold()

                Text(timeString(from: timerManager.countdown))
                    .font(.system(size: 72, weight: .bold, design: .monospaced))
                    .padding()

                ProgressView(value: timerManager.progressFraction)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .padding(.horizontal, 40)

                if !timerManager.timerRunning {
                    TextField("Enter seconds", text: $inputTime)
                        .keyboardType(.numberPad)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                        .frame(width: 200)
                }

                HStack(spacing: 30) {
                    if timerManager.timerRunning {
                        Button(action: {
                            timerManager.pauseOrResumeTimer()
                        }) {
                            Text(timerManager.isPaused ? "Resume" : "Pause")
                                .font(.headline)
                                .padding()
                                .frame(width: 100)
                                .background(Color.blue.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    } else {
                        Button(action: {
                            if let seconds = Int(inputTime), seconds > 0 {
                                timerManager.startCountdown(seconds)
                            }
                        }) {
                            Text("Start")
                                .font(.headline)
                                .padding()
                                .frame(width: 100)
                                .background(Color.green.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }

                    Button(action: {
                        timerManager.resetTimer()
                        inputTime = ""
                    }) {
                        Text("Reset")
                            .font(.headline)
                            .padding()
                            .frame(width: 100)
                            .background(Color.red.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Timer")
        }
    }

    private func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
}

#Preview {
    TimerView()
}
