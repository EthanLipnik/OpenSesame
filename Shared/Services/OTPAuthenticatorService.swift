//
//  OTPAuthenticatorService.swift
//  OTPAuthenticatorService
//
//  Created by Ethan Lipnik on 8/19/21.
//

import Foundation
import Combine
import SwiftOTP

class OTPAuthenticatorService: ObservableObject {
    // MARK: - Variables
    @Published var totp: TOTP? = nil
    @Published var verificationCode: String? = nil
    @Published var verificationCodeDate: Date? = nil
    
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
    
    private func generateCode(_ date: Date = Date()) {
        
    }
    
    func initialize(_ secret: String) {
        self.totp = TOTP(secret: base32DecodeToData(secret)!)
        
        self.verificationCode = totp?.generate(time: Date())
        self.verificationCodeDate = Date().nearestThirtySeconds()
    }
    
    func initialize(_ url: URL) { // otpauth://totp/{Website}:{Username}?secret={Secret}&issuer={Issuer}
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        guard let secret = components?.queryItems?.first(where: { $0.name == "secret" })?.value else { return }
        
        initialize(secret)
    }
    
    deinit {
        totp = nil
        
        timer?.invalidate()
        timer = nil
    }
}
