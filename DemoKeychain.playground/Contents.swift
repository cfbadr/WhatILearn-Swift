/*:
 ## DemoKeychain
 
 The purpose of this playground is to exploit the possibilty of the Keychain. In order to use in futur project.
 
 For work with keychains, we need to import `Security`
 */
import Foundation
import Security

enum KeychainError: Error{
    case save
}

func saveKey() throws{
    
    let key = "clé".data(using: .utf8)!
    let tag = "com.example.keys.mykey".data(using: .utf8)!
    
    let query = [
        kSecClass as String: kSecClassGenericPassword as String,
        kSecAttrAccount as String: tag,
        ] as [String: Any]
    
    
    SecItemAdd(query as CFDictionary, nil)
    
    let status = SecItemAdd(query as CFDictionary, nil)
    print(status)
    guard status == errSecSuccess else { throw  KeychainError.save  }
}

func getKey() throws{
    let tag = "com.example.keys.mykey".data(using: .utf8)!
    let getquery: [String: Any] = [kSecClass as String: kSecClassKey,
                                   kSecAttrApplicationTag as String: tag]
    var item: CFTypeRef?
    let status = SecItemCopyMatching(getquery as CFDictionary, &item)
    guard status == errSecSuccess else { throw  KeychainError.save  }
    print(status)
    let key = item as! SecKey
    print(key)
    
    //let key = item as! SecKey

}

saveKey()
getKey()

