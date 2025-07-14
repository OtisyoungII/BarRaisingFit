//
//  GlassEffectTabBar.swift
//  BarRaisingFit
//
//  Created by Otis Young on 7/14/25.
//

import SwiftUI

struct GlassEffectTabBar: View {
    @Binding var selectedTab: Tab

    var body: some View {
        HStack {
            tabButton(.metrics, icon: "waveform.path.ecg")
            tabButton(.activity, icon: "flame.fill")
            tabButton(.profile, icon: "person.crop.circle")
            tabButton(.settings, icon: "gearshape.fill")
        }
        .padding(.vertical, 12)
        .padding(.horizontal)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .shadow(radius: 8)
    }

    private func tabButton(_ tab: Tab, icon: String) -> some View {
        Button {
            selectedTab = tab
        } label: {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .medium))
                .foregroundColor(selectedTab == tab ? .blue : .gray)
                .frame(maxWidth: .infinity)
        }
    }
}
