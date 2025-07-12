//
//  AuthViewModel.swift
//  BarRaisingFit
//
//  Created by Otis Young on 7/12/25.
//

//import Foundation
//import Combine
//import Auth0
//import SwiftUI
//
//struct UserInfo {
//    var name: String?
//    var picture: String?
//}
//
//class AuthViewModel: ObservableObject {
//    @Published var isAuthenticated: Bool = false
//    @Published var userInfo: UserInfo?
//    func login() {
//        Auth0
//            .webAuth()
//            .scope("openid profile")
//            .audience("dev-xephk2wk8nzc8smw.us.auth0.com") // optional depending on setup
//            .start { result in
//                switch result {
//                case .success(let credentials):
//                    DispatchQueue.main.async {
//                        self.isAuthenticated = true
//                    }
//                    self.fetchUserProfile(accessToken: credentials.accessToken)
//                case .failure(let error):
//                    print("Login failed: \(error)")
//                }
//            }
//    }
//    func fetchUserProfile(accessToken: String) {
//        Auth0
//            .authentication()
//            .userInfo(withAccessToken: accessToken)
//            .start { result in
//                switch result {
//                case .success(let profile):
//                DispatchQueue.main.async {
//                    self.userInfo = UserInfo(name: profile.name)
//                }
//            case .failure(let error):
//                print("Failed to fetch profile: \(error)")
//            }
//        }
//    }
//    func logout() {
//        Auth0
//            .webAuth()
//            .clearSession { success in
//            DispatchQueue.main.async {
//                self.isAuthenticated = false
//                self.userInfo = nil
//            }
//        }
//    }
//}
//
//// MARK: - SwiftUI Preview
//
//struct AuthViewModel_Preview: View {
//    @StateObject var auth = AuthViewModel()
//    var body: some View {
//    VStack(spacing: 20) {
//    if auth.isAuthenticated {
//        Text("User is authenticated")
//        if let name = auth.userInfo?.name {
//            Text("Name: \(name)")
//        }
//        
//    } else {
//        Text("User is not authenticated")
//        
//    }
//    Button("Login") {
//        auth.login()
//    }
//    Button("Logout") {
//auth.logout()
//}
//}
//.padding()
//}
//}
//
//#Preview {
//    AuthViewModel_Preview()
//}
