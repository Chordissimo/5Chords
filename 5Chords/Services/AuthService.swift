//
//  AuthService.swift
//  AmDm AI
//
//  Created by Anton on 21/08/2024.
//

import FirebaseAuth
import SwiftUI


public struct AuthService {
    public static func getToken(completion: @escaping (String) -> Void) {
        let currentTimestamp: TimeInterval = NSDate().timeIntervalSince1970
        if Int(currentTimestamp - AppDefaults.tokenTimestamp) > 60 * 55 {
            Auth.auth().signInAnonymously() { result, error in
                if let err = error {
                    print(err)
                } else if let user = result?.user {
                    user.getIDToken() { token, error in
                        if let err = error {
                            print("FirebaseAuthError: failed to fetch token: \(err.localizedDescription)")
                        } else if let t = token {
                            AppDefaults.tokenTimestamp = NSDate().timeIntervalSince1970
                            AppDefaults.token = t
                            completion(t)
                        } else {
                            print("FirebaseAuthError: failed to fetch token.")
                        }
                    }
                } else {
                    print("FirebaseAuthError: failed to fetch signed in user.")
                }
            }
        } else {
            completion(AppDefaults.token)
        }
    }
}
