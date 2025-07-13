//
//  TimerManager.swift
//  BarRaisingFit
//
//  Created by Otis Young on 7/13/25.
//

import Foundation
import AudioToolbox
import SwiftUI

class TimerManager: ObservableObject {
    @Published var countdown: Int = 0
    @Published var totalTime: Int = 0
    @Published var timerRunning = false
    @Published var isPaused = false

    private var taskID = UUID()

    func startCountdown(_ time: Int) {
        countdown = time
        totalTime = time
        timerRunning = true
        isPaused = false
        taskID = UUID()

        Task {
            let currentTaskID = taskID
            while countdown > 0 && currentTaskID == taskID {
                if !isPaused {
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                    await MainActor.run {
                        countdown -= 1
                    }
                } else {
                    try? await Task.sleep(nanoseconds: 200_000_000)
                }
            }

            if countdown <= 0 && currentTaskID == taskID {
                await MainActor.run {
                    self.timerRunning = false
                    self.isPaused = false
                    self.playSystemSound()
                }
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

    private func playSystemSound() {
        AudioServicesPlaySystemSound(SystemSoundID(1005))
    }

    var progressFraction: Double {
        guard totalTime > 0 else { return 0 }
        return Double(totalTime - countdown) / Double(totalTime)
    }
}
