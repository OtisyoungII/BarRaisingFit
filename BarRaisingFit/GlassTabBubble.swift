//
//  GlassTabBubble.swift
//  BarRaisingFit
//
//  Created by Otis Young on 7/14/25.
//

import SwiftUI

struct GlassTabBubble: View {
    let width: CGFloat
    let index: Int
    let scale: CGFloat
    let colorScheme: ColorScheme
    let namespace: Namespace.ID

    var body: some View {
        Capsule()
            .fill(colorScheme == .dark ? Color.white.opacity(0.15) : Color.black.opacity(0.1))
            .background(
                Capsule()
                    .stroke(
                        colorScheme == .dark ? Color.white.opacity(0.3) : Color.black.opacity(0.15),
                        lineWidth: 1
                    )
            )
            .matchedGeometryEffect(id: "bubble", in: namespace)
            .frame(width: width * scale, height: 58 * scale) // increased vertical size
            .offset(x: CGFloat(index) * width - (width * (scale - 1) / 2), y: 0)
            .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.7), value: index)
    }
}
