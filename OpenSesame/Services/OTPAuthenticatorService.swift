//
//  OTPAuthenticatorService.swift
//  OTPAuthenticatorService
//
//  Created by Ethan Lipnik on 8/19/21.
//

import Combine
import Foundation
import SwiftOTP

class OTPAuthenticatorService: ObservableObject {
    // MARK: - Variables

    @Published
    var totp: TOTP?
    @Published
    var verificationCode: String?
    @Published
    var verificationCodeDate: Date?

    var timer: Timer?

    // MARK: - Init

    init() {
        startTimer()
    }

    init(_ url: URL) {
        initialize(url)

        startTimer()
    }

    init(_ secret: String) {
        initialize(secret)

        startTimer()
    }

    // MARK: - Functions

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
            self?.verificationCode = self?.totp?.generate(time: Date())
            self?.verificationCodeDate = Date().nearestThirtySeconds()
        })

        timer?.fire()
    }

    private func generateCode(_: Date = Date()) {}

    func initialize(_ secret: String) {
        totp = TOTP(secret: base32DecodeToData(secret)!)

        verificationCode = totp?.generate(time: Date())
        verificationCodeDate = Date().nearestThirtySeconds()
    }

    func initialize(_ url: URL) {
        // otpauth://totp/{Website}:{Username}?secret={Secret}&issuer={Issuer}
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        guard let secret = components?.queryItems?.first(where: { $0.name == "secret" })?.value
        else { return }

        initialize(secret)
    }

    deinit {
        totp = nil

        timer?.invalidate()
        timer = nil
    }
}
