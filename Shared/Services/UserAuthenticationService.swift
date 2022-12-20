//
//  UserAuthenticationService.swift
//  UserAuthenticationService
//
//  Created by Ethan Lipnik on 8/18/21.
//

import Combine
import LocalAuthentication

class UserAuthenticationService: ObservableObject {
    #if os(macOS)
        static let BiometricLogin = LAPolicy.deviceOwnerAuthenticationWithBiometricsOrWatch
    #else
        static let BiometricLogin = LAPolicy.deviceOwnerAuthenticationWithBiometrics
    #endif

    static var cancellables = Set<AnyCancellable>()

    static func authenticate(reason: String = "display your password") -> Future<Bool, Never> {
        return Future { promise in
            print("Requesting authentication")
            let context = LAContext()
            var error: NSError?

            func authenticateWithPassword() {
                context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, _ in
                    if success {
                        promise(.success(success))
                    } else {
                        promise(.success(false))
                    }
                }
            }

            // check whether biometric authentication is possible
            if context.canEvaluatePolicy(UserAuthenticationService.BiometricLogin, error: &error) {
                // it's possible, so go ahead and use it

                context.evaluatePolicy(UserAuthenticationService.BiometricLogin, localizedReason: reason) { success, _ in
                    // authentication has now completed
                    DispatchQueue.main.async {
                        if success {
                            // authenticated successfully
                            promise(.success(success))
                        } else {
                            authenticateWithPassword()
                        }
                    }
                }
            } else {
                authenticateWithPassword()
            }
        }
    }

    static func availableBiometrics() -> [BiometricType] {
        var error: NSError?
        let context = LAContext()
        var types: [BiometricType] = []
        #if os(macOS)
            let hasWatchAuthentication = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithWatch, error: &error)

            if hasWatchAuthentication {
                types.append(.watch)
            }
        #endif
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            switch context.biometryType {
            case .faceID:
                types.append(.faceID)
            case .touchID:
                types.append(.touchID)
            case .none:
                break
            @unknown default:
                break
            }
        }

        return types
    }

    enum BiometricType {
        case touchID
        case faceID

        case watch
    }
}
