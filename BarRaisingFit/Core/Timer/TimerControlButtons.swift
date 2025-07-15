//
//  TimerControlButtons.swift
//  BarRaisingFit
//
//  Created by Otis Young on 7/14/25.
//

import SwiftUI

struct TimerControlButtonsView: View {
    @ObservedObject var timer: TimerManager

    var body: some View {
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
}
