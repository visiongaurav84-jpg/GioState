//
//  EncryptionUtility.swift
//  goistats
//
//  Created by getitrent on 28/07/25.
//


import Foundation
import CommonCrypto
import CryptoKit
import Security
import UIKit

class EncryptionUtility {
    
    static let shared = EncryptionUtility()
    //PBKDF2 algorithm
    static let secretKeyFactoryAlgorithm = CCPBKDFAlgorithm(kCCPBKDF2)
    //HMAC-SHA256 as PRF
    static let prfAlgorithm = CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA256)
    static let salt = "763892479389216T"
    static let pwdIterations = 65536
    static let keySize = 32 // 256 bits = 32 bytes
    static let rsaEncryptAlgorithm = SecKeyAlgorithm.rsaEncryptionOAEPSHA1
    
    static let publicKeyBase64 = "MIIDijCCAnKgAwIBAgIJAIFc/lSRBanSMA0GCSqGSIb3DQEBCwUAMHMxCzAJBgNVBAYTAklOMQ4wDAYDVQQIEwVEZWxoaTESMBAGA1UEBxMJTmV3IERlbGhpMQ4wDAYDVQQKEwVNT1NQSTENMAsGA1UECxMERElJRDEhMB8GA1UEAxMYYXBpLmdvaXN0YXQubW9zcGkuZ292LmluMB4XDTI1MDIxMDA3MTg1N1oXDTI3MDEzMTA3MTg1N1owczELMAkGA1UEBhMCSU4xDjAMBgNVBAgTBURlbGhpMRIwEAYDVQQHEwlOZXcgRGVsaGkxDjAMBgNVBAoTBU1PU1BJMQ0wCwYDVQQLEwRESUlEMSEwHwYDVQQDExhhcGkuZ29pc3RhdC5tb3NwaS5nb3YuaW4wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCtsWCs/3+htg2SAwzQ1FDEYo5OCO/rONWHbHvqwNbK7ZUqI6rSh3MnvemJpsEVj6ePvj90jVetwQtv3wrR+nKejoojwY+uDxkC+mWCelPVMTbeZock/aJRYPy2nVXeuwyBp2jcR5+zfqrXvknBq7ScrImrCgSgae5EoPVO/15F/AAgWgnR9kEieD/OrOUyDyzWXFhvn4iAv9AqbZ8BgHqZ2VaduDXLAyDM+45thV+T+GxzOBeepwTJ+ygOTdbsfMlhSYbDj1Fkhk9ZRfZdP6WyJIYnuCSNa542ysNwggHYoQ7dSWegvXdv9zN3Bn4HJUmwWz7AbCNidtrF4Xr2aigrAgMBAAGjITAfMB0GA1UdDgQWBBS4h2DH9HNmvyJx+ni3tIJ+ALecXDANBgkqhkiG9w0BAQsFAAOCAQEAMv3V54g8ikWbtAt+ViE2Q9Oe0x3p7pd2gsfdzEpA0wtfjkCCJHxZJTyKoRjGXf0HB0+X0rb3VNbUZcm646rrVqd6yV2ATA9gRa5P0Lv6iVAW5j1lXXQAia8LOYe43qZxgyPpGDyqlXRjrtMMre616qP8rZdjGMvywcR4DFbmjdqAGN1VmjVckzbF64L9SYqiQrtnJOmbZjxZGiUdlMJIVfzeffb60UMB6byVu80W6hFiv3KdjwyJ8PRjgwN9c5lpaOma87I7zZng/DYtgUCVbgJZXPSYw6hTP6vyoOSSRhzzudEAzIzzR/UjgMDb65Uv6oMdW4DPbBAHgGBrheYpxA=="
    
    private init() {}
    
    //MARK: - Genrate Key
    static func generateKey(appId: String) -> String? {
        guard let passwordData = appId.data(using: .utf8),
              let saltData = salt.data(using: .utf8) else {
            return nil
        }
        
        var derivedKey = [UInt8](repeating: 0, count: keySize)
        let derivationStatus = CCKeyDerivationPBKDF(
            secretKeyFactoryAlgorithm,                  //kCCPBKDF2
            appId,
            passwordData.count,                         // password
            [UInt8](saltData),
            saltData.count,                             // salt
            prfAlgorithm,                               // HMAC-SHA256
            UInt32(pwdIterations),                      // iterations
            &derivedKey,
            keySize                                     // output buffer
        )
        
        guard derivationStatus == kCCSuccess else {
            print("Key derivation failed")
            return nil
        }
        
        return byteArrayToHex(derivedKey)
    }
    
    static func byteArrayToHex(_ bytes: [UInt8]) -> String {
        return bytes.map { String(format: "%02X", $0) }.joined()
    }
    static func dataToHex(_ data: Data) -> String {
        return data.map { String(format: "%02x", $0) }.joined()
    }
    
    // MARK: - RSA Encryption
    static func rsaEncrypt(text: String) -> String? {
        guard let publicKey = returnPubKey() else {
            //print("Public key not found")
            return nil
        }
        
        guard let plainData = text.data(using: .utf8) else {
            return nil
        }
        
        guard SecKeyIsAlgorithmSupported(publicKey, .encrypt, rsaEncryptAlgorithm) else {
           // print("Algorithm not supported")
            return nil
        }
        
        var error: Unmanaged<CFError>?
        guard let encryptedData = SecKeyCreateEncryptedData(publicKey, rsaEncryptAlgorithm, plainData as CFData, &error) as Data? else {
            print("Encryption failed: \(error?.takeRetainedValue().localizedDescription ?? "unknown error")")
            return nil
        }
        
        return encryptedData.base64EncodedString()
    }
    
    // MARK: - Public Key from X.509 Base64 Certificate
    static func returnPubKey() -> SecKey? {
        guard let certData = Data(base64Encoded: publicKeyBase64) else {
            //print("Failed to base64 decode public key")
            return nil
        }
        
        guard let certificate = SecCertificateCreateWithData(nil, certData as CFData) else {
            print("Failed to create SecCertificate")
            return nil
        }
        
        var trust: SecTrust?
        let policy = SecPolicyCreateBasicX509()
        
        let status = SecTrustCreateWithCertificates(certificate, policy, &trust)
        guard status == errSecSuccess, let trustObj = trust else {
            print("Failed to create trust object")
            return nil
        }
        
        return SecTrustCopyKey(trustObj)
    }
    
    // MARK: - SHA256 Checksum
    static func sha256Checksum(_ input: String) -> String {
        let data = Data(input.utf8)
        let hashed = SHA256.hash(data: data)
        return Data(hashed).base64EncodedString()
    }
    
    // MARK: - JSON to String
    static func jsonStringPreservingKeyOrder(from dict: NSDictionary, orderedKeys: [String]) -> String? {
        var json = "{"
        for (index, key) in orderedKeys.enumerated() {
            guard let value = dict[key] else { continue }
            
            let escapedKey = "\"\(key)\""
            var valueString = ""
            
            switch value {
            case let string as String:
                valueString = "\"\(string)\""
            case let number as NSNumber:
                // NSNumber can be Bool or Number
                valueString = CFGetTypeID(number) == CFBooleanGetTypeID()
                ? (number.boolValue ? "true" : "false")
                : "\(number)"
            case is NSNull:
                valueString = "null"
            case let subDict as NSDictionary:
                if let nested = jsonStringPreservingKeyOrder(from: subDict, orderedKeys: subDict.allKeys as! [String]) {
                    valueString = nested
                }
            case let array as NSArray:
                if let data = try? JSONSerialization.data(withJSONObject: array, options: []),
                   let arrayString = String(data: data, encoding: .utf8) {
                    valueString = arrayString
                }
            default:
                continue  // Skip unsupported types
            }
            
            json += "\(escapedKey):\(valueString)"
            if index < orderedKeys.count - 1 {
                json += ","
            }
        }
        json += "}"
        return json
    }
    
    // MARK: - UUID Generation & Storage
    static func getUniqueAppId() -> String {
        if let uuid = UIDevice.current.identifierForVendor?.uuidString {
            return uuid
        }
        // Fallback in case identifierForVendor is unavailable
        return UUID().uuidString
    }
    
    // MARK: - Device Model Indentifier
    static func deviceModelName() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        
        let identifier = withUnsafePointer(to: &systemInfo.machine) {
            ptr in String(cString: UnsafeRawPointer(ptr).assumingMemoryBound(to: CChar.self))
        }
        
        let modelMap: [String: String] = [
            // iPhone XR to iPhone 15 Series
            "iPhone11,8": "iPhone XR",
            "iPhone11,2": "iPhone XS",
            "iPhone11,6": "iPhone XS Max",
            "iPhone12,1": "iPhone 11",
            "iPhone12,3": "iPhone 11 Pro",
            "iPhone12,5": "iPhone 11 Pro Max",
            "iPhone13,1": "iPhone 12 mini",
            "iPhone13,2": "iPhone 12",
            "iPhone13,3": "iPhone 12 Pro",
            "iPhone13,4": "iPhone 12 Pro Max",
            "iPhone14,4": "iPhone 13 mini",
            "iPhone14,5": "iPhone 13",
            "iPhone14,2": "iPhone 13 Pro",
            "iPhone14,3": "iPhone 13 Pro Max",
            "iPhone14,6": "iPhone SE (3rd generation)",
            "iPhone15,2": "iPhone 14 Pro",
            "iPhone15,3": "iPhone 14 Pro Max",
            "iPhone14,7": "iPhone 14",
            "iPhone14,8": "iPhone 14 Plus",
            "iPhone15,4": "iPhone 15",
            "iPhone15,5": "iPhone 15 Plus",
            "iPhone16,1": "iPhone 15 Pro",
            "iPhone16,2": "iPhone 15 Pro Max",
            
            // iPhone 16 Series (assumed identifiers; adjust as confirmed)
            "iPhone17,1": "iPhone 16",
            "iPhone17,2": "iPhone 16 Plus",
            "iPhone17,3": "iPhone 16 Pro",
            "iPhone17,4": "iPhone 16 Pro Max"
        ]
        
        return modelMap[identifier] ?? identifier
    }
    
    // MARK: - Key Derivation
    static func deriveKey(from password: String) -> SymmetricKey? {
        guard let passwordData = password.data(using: .utf8),
              let saltData = EncryptionUtility.salt.data(using: .utf8) else {
            return nil
        }
        
        var derivedKeyData = Data(count: EncryptionUtility.keySize)
        
        let result = derivedKeyData.withUnsafeMutableBytes { derivedKeyBytes in
            saltData.withUnsafeBytes { saltBytes in
                CCKeyDerivationPBKDF(
                    CCPBKDFAlgorithm(kCCPBKDF2),
                    password, passwordData.count,
                    saltBytes.bindMemory(to: UInt8.self).baseAddress!,
                    saltData.count,
                    CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA256),
                    UInt32(EncryptionUtility.pwdIterations),
                    derivedKeyBytes.bindMemory(to: UInt8.self).baseAddress!,
                    EncryptionUtility.keySize
                )
            }
        }
        
        if result == kCCSuccess {
            return SymmetricKey(data: derivedKeyData)
        } else {
            print("Key derivation failed with status: \(result)")
            return nil
        }
    }
    
    // MARK: - AES-GCM Encryption
    static func encrypt(plainText: String, password: String) -> String? {
        guard let plainData = plainText.data(using: .utf8),
              let key = deriveKey(from: password) else {
            print("Invalid plain text or key derivation failed")
            return nil
        }
        
        // Get IV from UserDefaults or generate one if missing
        let ivData: Data
        if let base64IV = KeychainService.getIV(),
           let storedIVData = Data(base64Encoded: base64IV as String),
           storedIVData.count == 12 {
            ivData = storedIVData
            print("Base64 IV: \(ivData.base64EncodedString())")
            print("IV loaded from UserDefaults")
        } else {
            ivData = getIV() // Generates and stores a new IV
            print("IV generated via getIV()")
        }
        
        // Create AES.GCM.Nonce
        guard let nonce = try? AES.GCM.Nonce(data: ivData) else {
            print("Invalid IV format for AES-GCM")
            return nil
        }
        
        // Encrypt
        do {
            let sealedBox = try AES.GCM.seal(plainData, using: key, nonce: nonce)
            var resultData = Data()
            resultData.append(sealedBox.ciphertext)
            resultData.append(sealedBox.tag)
            
            return resultData.base64EncodedString()
        } catch {
            print("Encryption error: \(error)")
            return nil
        }
    }
    
    // MARK: - IV Handling
    static func getIV() -> Data {
        let defaults = UserDefaults.standard
        // If not found, generate a new 12-byte IV and store it
        let ivData = Data((0..<12).map { _ in UInt8.random(in: 0...255) })
        let base64IV = ivData.base64EncodedString()
        defaults.set(base64IV, forKey: "ivKey")
        
        // let accesToken = dict.data?.accessToken ?? ""
        KeychainService.saveIV(IV: base64IV as NSString)
        
        // Check if ivKey is missing or empty — only then set it
        //        if let existingIV = defaults.string(forKey: "ivKey"), existingIV.isEmpty {
        //            defaults.set(base64IV, forKey: "ivKey")
        //        }
        
        print("uniqueIVId3: \(base64IV)")
        return ivData
    }
    
    
}
