//
//  GlassEffectTabBar.swift
//  BarRaisingFit
//
//  Created by Otis Young on 7/14/25.
//

import SwiftUI

struct GlassEffectTabBar: View {
    @Binding var selectedTab: Tab
    @Namespace private var bubbleAnimation
    @Environment(\.colorScheme) var colorScheme
    
    private let tabs: [Tab] = [.metrics, .activity, .history, .profile, .settings]
    @State private var dragIndex: Int? = nil
    
    var body: some View {
        GeometryReader { fullGeo in
            HStack(spacing: 0) {
                ForEach(tabs.indices, id: \.self) { idx in
                    tabButton(for: tabs[idx], at: idx, fullGeo: fullGeo)
                }
            }
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .overlay(
                GlassTabBubble(
                    width: fullGeo.size.width / CGFloat(tabs.count),
                    index: dragIndex ?? tabs.firstIndex(of: selectedTab)!,
                    scale: dragIndex != nil ? 1.1 : 1.0,
                    colorScheme: colorScheme,
                    namespace: bubbleAnimation
                ),
                alignment: .leading
            )
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            .gesture(dragGesture(fullGeo: fullGeo))
        }
        .frame(height: 70)
        .padding(.horizontal, 12)
    }
    
    private func tabButton(for tab: Tab, at index: Int, fullGeo: GeometryProxy) -> some View {
        VStack(spacing: 4) {
            Image(systemName: iconName(for: tab))
                .font(.system(size: 20, weight: .medium))
            Text(labelName(for: tab))
                .font(.caption2)
        }
        .foregroundStyle(selectedTab == tab ? Color("Teal1") : Color.secondary)
        .frame(width: fullGeo.size.width / CGFloat(tabs.count), height: 70)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = tab
                dragIndex = nil
            }
        }
    }
    
    private func dragGesture(fullGeo: GeometryProxy) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                let width = fullGeo.size.width / CGFloat(tabs.count)
                let idx = min(max(Int(value.location.x / width), 0), tabs.count - 1)
                dragIndex = idx
            }
            .onEnded { value in
                let width = fullGeo.size.width / CGFloat(tabs.count)
                let idx = min(max(Int(value.location.x / width), 0), tabs.count - 1)
                withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.7)) {
                    selectedTab = tabs[idx]
                    dragIndex = nil
                }
            }
    }
    
    // Helpers
    private func iconName(for tab: Tab) -> String {
        switch tab {
        case .metrics: return "waveform.path.ecg"
        case .activity: return "flame.fill"
        case .profile: return "person.crop.circle"
        case .settings: return "gearshape.fill"
        case .history: return "clock.arrow.circlepath" // ⏱ or use "clock"
        }
    }
    
    private func labelName(for tab: Tab) -> String {
        switch tab {
        case .metrics: return "Metrics"
        case .activity: return "Activity"
        case .profile: return "Profile"
        case .settings: return "Settings"
        case .history: return "History"
        }
    }
}
