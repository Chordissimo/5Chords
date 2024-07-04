//
//  AppCheckService.swift
//  AmDm AI
//
//  Created by Anton on 04/07/2024.
//

import Foundation
import Combine
import Firebase
import FirebaseAppCheck

public enum TokenError: Error {
    case error(_ with: String)
}

public protocol AppCheckManaging: AppCheckProviderFactory { }

public final class AppCheckManager: NSObject, AppCheckManaging {
    /// MARK: - Variables
    public static let shared = AppCheckManager()
    
    /// MARK: - Methods
    public func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
#if DEBUG
        // App Attest is not available on debug builds and/or simulators.
        return AppCheckDebugProvider(app: app)
#else
        // Use App Attest provider on release builds and/or real devices.
        return AppAttestProvider(app: app)
#endif
    }
    
    public func generateTokenAppCheck() -> Future<String, TokenError> {
        Future<String, TokenError> { promise in
            AppCheck.appCheck().token(forcingRefresh: false) { token, error in
                if let error {
                    promise(.failure(.error(error.localizedDescription)))
                    return
                }
                guard let tokenref = token else { return }
                promise(.success(tokenref.token))
            }
        }
    }
    
    public func setProviderFactory() {
        AppCheck.setAppCheckProviderFactory(self)
    }
}
