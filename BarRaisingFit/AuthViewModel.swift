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
    
    private let domain = "dev-xephk2wk8nzc8smw.us.auth0.com"
    private let clientId = "8fII96RVaxeLVW9MY26kVCPbludB43G7"
    
    func login(completion: @escaping (Bool) -> Void) {
        Auth0.webAuth(clientId: clientId, domain: domain)
            .scope("openid profile email read:current_user update:current_user_metadata")
            .audience("https://\(domain)/api/v2/")
            .start { result in
                switch result {
                case .success(let credentials):
                    self.isAuthenticated = true
                    self.accessToken = credentials.accessToken
                    self.idToken = credentials.idToken
                    self.fetchUserProfile()
                    completion(true)
                case .failure(let error):
                    print("Auth0 Login Error:", error)
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
                }
            }
    }
    func fetchUserProfile() {
        guard let idToken = idToken else { return }
        
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
                
                if let token = self.accessToken {
                    Auth0.users(token: token)
                        .get("auth0|\(jwt.subject ?? "")")
                        .start { result in
                            switch result {
                            case .success(let user):
                                if let meta = user["user_metadata"] as? [String: Any] {
                                    let gender = meta["gender"] as? String
                                    let goal = meta["goal"] as? String
                                    let age = meta["age"] as? Int ?? 0
                                    
                                    DispatchQueue.main.async {
                                        self.userProfile?.gender = gender
                                        self.userProfile?.goal = goal
                                        self.userProfile?.age = age
                                    }
                                }
                            case .failure(let error):
                                print("Failed to fetch user metadata: \(error)")
                            }
                        }
                }
            }
            
        } catch {
            print("JWT Decode Error:", error)
        }
    }
}
