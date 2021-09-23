//
//  UserManager.swift
//  MemoryTrace
//
//  Created by seunghwan Lee on 2021/09/22.
//

import Foundation

@propertyWrapper
struct UserDefault<T> {
    let key: String
    let defaultValue: T
    
    var wrappedValue: T {
        get {
            let udValue = UserDefaults.standard.object(forKey: key) as? T
            switch (udValue as Any) {
            case Optional<Any>.some(let value):
                return value as! T
            case Optional<Any>.none:
                return defaultValue
            default:
                return udValue ?? defaultValue
            }
        }
        set {
            switch (newValue as Any) {
            case Optional<Any>.some(let value):
                UserDefaults.standard.set(value, forKey: key)
            case Optional<Any>.none:
                UserDefaults.standard.removeObject(forKey: key)
            default:
                UserDefaults.standard.set(newValue, forKey: key)
            }
        }
    }
}

final class UserManager {
    @UserDefault(key: "jwt", defaultValue: nil)
    static var jwt: String?
    
    @UserDefault(key: "fcmToken", defaultValue: nil)
    static var fcmToken: String?
    
    @UserDefault(key: "name", defaultValue: nil)
    static var name: String?
    
    @UserDefault(key: "uid", defaultValue: 0)
    static var uid: Int
    
    @UserDefault(key: "snsType", defaultValue: nil)
    static var snsType: String?
    
    @UserDefault(key: "signInDate", defaultValue: nil)
    static var signInDate: String?
}
