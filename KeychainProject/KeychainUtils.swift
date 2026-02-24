//
//  KeychainUtils.swift
//  KeychainProject
//
//  Created by user on 2/24/26.
//

import Foundation

enum KeychainError: Error {
    case unexpectedStatus(OSStatus)
}

// -25303 = errSecInteractionNotAllowed => 암호화된 인증서에 사용하는 'kSecAttrApplicationLabel' 제거
// -25299 = errSecDuplicateItem => 중복 아이템
// -34018 = errSecMissingEntitlement => accessGroup entitlements, capabilities 설정 필요

class KeychainUtils {
    
    // Keychain은 Keychain에 저장이 되기 때문에, 앱을 삭제하더라도 정보가 삭제되지 않음
    // Keychain에는 잠금 기능이 존재, 잠긴 상태에서는 아이템 값의 접근, 복호화 등 작업이 불가능함
    
    private let bundleIdentifier = Bundle.main.bundleIdentifier!
    private let accessGroup = "com.ming.keychain.accessgroup"
    
    func save(bundleIdentifier: String? = nil, key: String, data: Data) throws {
        
        let bundleIdentifier = bundleIdentifier ?? self.bundleIdentifier
        
        let query: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecAttrService: bundleIdentifier,
//            kSecAttrAccessGroup: accessGroup, // Keychain에 저장되기 때문에 유니크한 identifier으로 앱간의 공유 데이터로 사용
            kSecValueData: data
        ]
        
        let status = SecItemAdd(query, nil)
        
        if status != errSecSuccess {
            print("Keychain Save Error: \(status)")
            throw KeychainError.unexpectedStatus(status)
        }
    }
    
    func delete(bundleIdentifier: String? = nil, key: String) throws {
        
        let bundleIdentifier = bundleIdentifier ?? self.bundleIdentifier
        
        let query: NSDictionary = [
               kSecClass: kSecClassGenericPassword,
               kSecAttrAccount: key,
               kSecAttrService: bundleIdentifier,
//               kSecAttrAccessGroup: accessGroup
           ]
        
        let status = SecItemDelete(query)
        if status != errSecSuccess {
            print("Keychain Delete Error: \(status)")
            throw KeychainError.unexpectedStatus(status)
        }
    }
    
    func read(bundleIdentifier: String? = nil, key: String) throws -> Data? {
        
        let bundleIdentifier = bundleIdentifier ?? self.bundleIdentifier
        
        var item: CFTypeRef?
        
        let query: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecAttrService: bundleIdentifier,
//            kSecAttrAccessGroup: accessGroup,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ]
        
        let status = SecItemCopyMatching(query, &item)
        
        if status == errSecItemNotFound {
            return nil
        }

        guard status == errSecSuccess else {
            print("Keychain Read Error: \(status)")
            throw KeychainError.unexpectedStatus(status)
        }
        
        return item as? Data
    }
    
    func update(bundleIdentifier: String? = nil, key: String, data: Data) throws {
        
        let bundleIdentifier = bundleIdentifier ?? self.bundleIdentifier
        
        let query: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecAttrService: bundleIdentifier,
//            kSecAttrAccessGroup: accessGroup
        ]

        let attributes: NSDictionary = [
            kSecValueData: data
        ]

        let status = SecItemUpdate(
            query,
            attributes
        )

        guard status == errSecSuccess else {
            print("Keychain Update Error: \(status)")
            throw KeychainError.unexpectedStatus(status)
        }
    }
}
