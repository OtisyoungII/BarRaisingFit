//
//  AuthViewModel.swift
//  BarRaisingFit
//
//  Created by Otis Young on 7/12/25.
//

import Foundation
import Auth0
import JWTDecode
import SwiftUI

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var accessToken: String?
    @Published var idToken: String?
    @Published var userProfile: UserProfile?
    @Published var userId: String?
    
    private let domain = "dev-xephk2wk8nzc8smw.us.auth0.com"
    private let clientId = "8fII96RVaxeLVW9MY26kVCPbludB43G7"
    
    func login(completion: @escaping (Bool) -> Void = { _ in }) {
        Auth0
            .webAuth(clientId: clientId, domain: domain)
            .scope("openid profile email read:current_user read:users")
            .audience("https://\(domain)/api/v2/")
            .start { result in
            switch result {
            case .success(let credentials):
                self.isAuthenticated = true
                self.accessToken = credentials.accessToken
                self.idToken = credentials.idToken
                
                
                do {
                    let jwt = try decode(jwt: credentials.idToken)
                    self.userId = jwt.subject
                } catch {
                    print("JWT Decode Error:", error)
                }
                
                
                self.fetchUserProfile()
                completion(true)
                
            case .failure(let error):
                if case .userCancelled = error {
                    print("User cancelled login.")
                }
                else {
                        print("Auth0 Login Error:", error)
                    }
                completion(false)
            }
        }
    }
    
    func logout() {
        Auth0.webAuth(clientId: clientId, domain: domain)
            .clearSession { _ in
            DispatchQueue.main.async {
                self.isAuthenticated = false
                self.userProfile = nil
                self.accessToken = nil
                self.idToken = nil
                self.userId = nil
            }
        }
    }
    
    func fetchUserProfile() {
        guard let idToken = idToken, let accessToken = accessToken else { return }
        
        do {
            let jwt = try decode(jwt: idToken)
            let name = jwt.claim(name: "name").string ?? "User"
            let picture = jwt.claim(name: "picture").string
            let url = picture.flatMap(URL.init)
            
            DispatchQueue.main.async {
                if self.userProfile == nil {
                    self.userProfile = UserProfile(
                        name: name,
                        age: 0,
                        heightInFeet: 0,
                        heightInInches: 0,
                        weightInPounds: 0,
                        gender: nil,
                        dateJoined: Date(),
                        goal: nil,
                        profilePictureURL: url
                    )
                }
                
                if let userId = jwt.subject {
                    Auth0.users(token: accessToken)
                        .get(userId)
                        .start { result in
                        switch result {
                        case .success(let user):
                            if let meta = user["user_metadata"] as? [String: Any] {
                                let gender = meta["gender"] as? String
                                let goal = meta["goal"] as? String
                                let age = meta["age"] as? Int ?? 0
                                let startingWeight = meta["starting_weight"] as? Double ?? 0.0
                                self.userProfile?.weightInPounds = startingWeight
                                let workouts = meta["workouts"] as? [[String: Any]] ?? []
                                
                                DispatchQueue.main.async {
                                    self.userProfile?.gender = gender
                                    self.userProfile?.goal = goal
                                    self.userProfile?.age = age
                                    self.userProfile?.weightInPounds = startingWeight
                                    print("User workouts: \(workouts)")
                                }
                            }
                        case .failure(let error):
                            print("Failed to fetch user metadata: \(error)")
                        }
                    }
                }
            }
        }
        catch {
                print("JWT Decode Error:", error)
            }
    }
}
