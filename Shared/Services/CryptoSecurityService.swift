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
    
    // MARK: - Functions
    static func loadEncryptionKey(hexString: String) {
        let key = SymmetricKey(data: Data(hexString: hexString)!)
        encryptionKey = key
    }
    
    static func loadEncryptionKey(_ string: String, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .userInitiated).async {
            encryptionKey = generateKey(fromString: string)
            
            completion?()
        }
    }
    
    static func generateKey(fromString string: String) -> SymmetricKey? {
        let stringData = string.data(using: .utf8)
        let base64Encoded = stringData!.base64EncodedData()
        let keyHash = SHA256.hash(data: base64Encoded)
        return SymmetricKey(data: keyHash)
    }
    
    static func decrypt(_ combinedData: Data, encryptionKey: SymmetricKey? = encryptionKey) throws -> String? {
        guard let key = encryptionKey else { throw CocoaError(.coderInvalidValue) }
        
        let sealedBox = try AES.GCM.SealedBox(combined: combinedData)
        let decryptedData = try AES.GCM.open(sealedBox, using: key)
        
        return String(decoding: decryptedData, as: UTF8.self)
    }
    
    static func decrypt(_ string: String, tag: String, nonce nonceStr: String) throws -> String? {
        guard let key = encryptionKey else { throw CocoaError(.coderInvalidValue) }
        
        let nonce = Data(hexString: nonceStr)
        
        guard let ciphertext = Data(base64Encoded: string) else { throw CocoaError(.coderReadCorrupt) }
        let tag = Data(hexString: tag)
        
        let sealedBox = try AES.GCM.SealedBox(nonce: AES.GCM.Nonce(data: nonce!),
                                               ciphertext: ciphertext,
                                               tag: tag!)

        let decryptedData = try AES.GCM.open(sealedBox, using: key)
        
        return String(decoding: decryptedData, as: UTF8.self)
    }
    
    static func encrypt(_ string: String, encryptionKey: SymmetricKey? = encryptionKey) throws -> Data? {
        guard let key = encryptionKey else { throw CocoaError(.coderValueNotFound) }
        
        let plainData = string.data(using: .utf8)
        let sealedData = try AES.GCM.seal(plainData!, using: key)
        let combined = sealedData.combined
        
        return combined
    }
    
    static func randomString(length: Int, numbersOnly: Bool = false, method: StringGeneratorMethod = .regular) -> String? {
        
        switch method {
        case .regular:
            var letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            
            if numbersOnly {
                letters = "123456789"
            }
            
            let len = UInt32(letters.length)
            
            var randomString = ""
            
            for _ in 0 ..< length {
                let rand = arc4random_uniform(len)
                var nextChar = letters.character(at: Int(rand))
                randomString += NSString(characters: &nextChar, length: 1) as String
            }
            
            return randomString
        case .cryptic:
            let nonce = NSMutableData(length: length)!
            let result = SecRandomCopyBytes(kSecRandomDefault, nonce.length, nonce.mutableBytes)
            if result == errSecSuccess {
                return (nonce as Data).base64EncodedString()
            } else {
                return nil
            }
        }
    }
    
    static func runEncryptionTest(_ password: String) -> Bool {
        if let test = try? OpenSesameKeychain()
            .synchronizable(true)
            .getData("encryptionTest") {
            
            return (try? decrypt(test, encryptionKey: CryptoSecurityService.generateKey(fromString: password))) != nil
        } else {
            return false
        }
    }
    
    enum StringGeneratorMethod {
        case regular
        case cryptic
    }
}
