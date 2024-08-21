//
//  AuthService.swift
//  AmDm AI
//
//  Created by Anton on 21/08/2024.
//

import Foundation
import AuthenticationServices
import FirebaseAuth
import FirebaseCore

@MainActor
class AuthService: ObservableObject {
    @Published var user: User?
    @Published var authenticated: Bool = false
    
    func signInAnonymously() async throws -> AuthDataResult? {
        do {
            let result = try await Auth.auth().signInAnonymously()
            self.user = result.user
            print("FirebaseAuthSuccess: Sign in anonymously, UID:(\(String(describing: result.user.uid)))")
            return result
        }
        catch {
            print("FirebaseAuthError: failed to sign in anonymously: \(error.localizedDescription)")
            throw error
        }
    }
    
    func getToken(completion: @escaping (String) -> Void) {
        self.user?.getIDToken() { token, error in
            if let err = error {
                print("FirebaseAuthError: failed to fetch token: \(err.localizedDescription)")
            } else if let t = token {
                completion(t)
            } else {
                completion("")
                print("FirebaseAuthError: failed to fetch token.")
            }
        }
    }
}

