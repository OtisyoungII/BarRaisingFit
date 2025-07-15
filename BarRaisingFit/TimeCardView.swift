//
//  TimeCardView.swift
//  BarRaisingFit
//
//  Created by Otis Young on 7/14/25.
//

import SwiftUI

struct TimerCardView: View {
    @ObservedObject var timer: TimerManager

    var body: some View {
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
    }
}
