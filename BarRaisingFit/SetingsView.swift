//
//  SetingsView.swift
//  BarRaisingFit
//
//  Created by Otis Young on 7/14/25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var profileVM: UserProfileViewModel

    @Binding var hideTabBar: Bool
    @State private var scrollOffset: CGFloat = 0
    @State private var showLogoutConfirmation = false

    var body: some View {
        ScrollView {
            GeometryReader { geo in
                Color.clear
                    .preference(key: ScrollOffsetKey.self, value: geo.frame(in: .global).minY)
            }
            .frame(height: 0)

            VStack(alignment: .leading, spacing: 24) {
                // Account Section
                HStack(spacing: 16) {
                    if let url = profileVM.profile.profilePictureURL {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                            case .failure:
                                Image(systemName: "person.crop.circle.badge.exclamationmark")
                                    .resizable()
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.gray)
                    }

                    VStack(alignment: .leading) {
                        Text(profileVM.profile.name)
                            .font(.title2)
                            .bold()
                        Text(authVM.isAuthenticated ? "Logged in" : "Logged out")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }

                // Action Section
                VStack(spacing: 12) {
                    Button(role: .destructive) {
                        showLogoutConfirmation = true
                    } label: {
                        Label("Logout", systemImage: "arrow.backward.square")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .confirmationDialog("Are you sure you want to log out?", isPresented: $showLogoutConfirmation) {
                        Button("Logout", role: .destructive) {
                            authVM.logout()
                            profileVM.resetToDefault()
                        }
                        Button("Cancel", role: .cancel) { }
                    }
                }

                // App Info Section
                VStack(alignment: .leading, spacing: 4) {
                    Text("App Version")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("1.0.0")
                        .font(.body)
                }

                Spacer()
            }
            .padding()
        }
        .onPreferenceChange(ScrollOffsetKey.self) { offset in
            withAnimation {
                hideTabBar = offset < -50
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    SettingsView(hideTabBar: .constant(false))
        .environmentObject(AuthViewModel())
        .environmentObject(UserProfileViewModel())
}
