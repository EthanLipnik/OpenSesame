//
//  CryptoSecurityService.swift
//  CryptoSecurityService
//
//  Created by Ethan Lipnik on 8/18/21.
//

import Foundation
import CryptoKit
import KeychainAccess

class CryptoSecurityService {
    // MARK: - Variables
    static var encryptionKey: SymmetricKey?
    static var nonce: Data?
    static var nonceStr: String?
    
    // MARK: - Functions
    static func loadNonce() {
        DispatchQueue.global(qos: .userInitiated).async {
            let keychain = Keychain(service: "com.ethanlipnik.OpenSesame", accessGroup: "B6QG723P8Z.OpenSesame")
            
            if let nonce = try? keychain.get("nonce") {
                self.nonce = Data(hexString: nonce)
                self.nonceStr = nonce
            } else {
                let nonce = randomString(length: 24).asHexString
                try? keychain.set(nonce, key: "nonce")
                self.nonce = Data(hexString: nonce)
                self.nonceStr = nonce
            }
        }
    }
    
    static func loadEncryptionKey(hexString: String) {
        let key = SymmetricKey(data: Data(hexString: hexString)!)
        encryptionKey = key
    }
    
    static func loadEncryptionKey(_ string: String, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .userInitiated).async {
            let stringData = string.data(using: .utf8)
            let base64Encoded = stringData!.base64EncodedData()
            let keyHash = SHA256.hash(data: base64Encoded)
            let key = SymmetricKey(data: keyHash)
            encryptionKey = key
            
            completion?()
        }
    }
    
    static func decrypt(_ string: String, tag: String, nonce nonceStr: String? = nil) throws -> String? {
        guard let key = encryptionKey else { throw CocoaError(.coderInvalidValue) }
        
        var nonce: Data?
        
        if let str = nonceStr {
            nonce = Data(hexString: str)
        } else {
            nonce = self.nonce
        }
        
        guard let ciphertext = Data(base64Encoded: string) else { throw CocoaError(.coderReadCorrupt) }
        let tag = Data(hexString: tag)
        
        let sealedBox = try AES.GCM.SealedBox(nonce: AES.GCM.Nonce(data: nonce!),
                                               ciphertext: ciphertext,
                                               tag: tag!)

        let decryptedData = try AES.GCM.open(sealedBox, using: key)
        
        return String(decoding: decryptedData, as: UTF8.self)
    }
    
    static func encrypt(_ string: String) throws -> (value: String, tag: String)? {
        guard let key = encryptionKey else { throw CocoaError(.coderValueNotFound) }
        
        let plainData = string.data(using: .utf8)
        let sealedData = try AES.GCM.seal(plainData!, using: key, nonce: AES.GCM.Nonce(data: nonce!))
        
        return (sealedData.ciphertext.base64EncodedString(), sealedData.tag.hexadecimal)
    }
    
    static func randomString(length: Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
}
