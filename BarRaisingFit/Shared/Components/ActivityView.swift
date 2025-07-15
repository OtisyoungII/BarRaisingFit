//
//  ActivityView.swift
//  BarRaisingFit
//
//  Created by Otis Young on 7/14/25.
//

import SwiftUI

struct ActivityView: View {
    @Binding var hideTabBar: Bool
    @State private var scrollOffset: CGFloat = 0

    var body: some View {
        ScrollView {
            GeometryReader { geo in
                Color.clear
                    .preference(key: ScrollOffsetKey.self, value: geo.frame(in: .global).minY)
            }
            .frame(height: 0)

            VStack(spacing: 20) {
                Text("Activity Summary")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)

                // Example metric cards (replace with real HealthKit data as needed)
                MetricCard(title: "Steps", value: "7,580")
                MetricCard(title: "Distance", value: "3.4 mi")
                MetricCard(title: "Calories", value: "320 kcal")
            }
            .padding()
        }
        .onPreferenceChange(ScrollOffsetKey.self) { offset in
            withAnimation {
                hideTabBar = offset < -50
            }
        }
        .navigationTitle("Activity")
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    ActivityView(hideTabBar: .constant(false))
}
