//
//  AuthViewModel.swift
//  BarRaisingFit
//
//  Created by Otis Young on 7/12/25.
//

import Foundation
import Auth0
import Combine

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var userName: String = ""
    @Published var profilePictureURL: URL?  // ✅ String now

    func login(completion: @escaping () -> Void = {}) {
        Auth0
            .webAuth()
            .scope("openid profile")
            .start { result in
                switch result {
                case .success(let credentials):
                    self.isAuthenticated = true
                    self.fetchUserProfile(accessToken: credentials.accessToken, completion: completion)
                case .failure(let error):
                    print("Login failed: \(error)")
                }
            }
    }

    private func fetchUserProfile(accessToken: String, completion: @escaping () -> Void) {
        Auth0
            .authentication()
            .userInfo(withAccessToken: accessToken)
            .start { result in
                switch result {
                case .success(let profile):
                    DispatchQueue.main.async {
                        self.userName = profile.name ?? "User"
                        self.profilePictureURL = profile.picture  // ✅ No URL conversion
                        completion()
                    }
                case .failure(let error):
                    print("Failed to fetch profile: \(error)")
                }
            }
    }

    func logout() {
        Auth0
            .webAuth()
            .clearSession { success in
                DispatchQueue.main.async {
                    self.isAuthenticated = false
                    self.userName = ""
                    self.profilePictureURL = nil
                }
            }
    }
}
