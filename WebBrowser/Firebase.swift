//
//  Firebase.swift
//  WebBrowser
//
//  Created by yangjian on 2023/6/20.
//

import Foundation
import Foundation
import Firebase

class FirebaseItem: NSObject {
    
    static let `default` = FirebaseItem()
    
    
    func log(event: AppState.FirebaseState.Event, params: [String: Any]? = nil) {
        
        if event.first {
            if UserDefaults.standard.bool(forKey: event.rawValue) == true {
                return
            } else {
                UserDefaults.standard.set(true, forKey: event.rawValue)
            }
        }
        
        #if DEBUG
        #else
        Analytics.logEvent(event.rawValue, parameters: params)
        #endif
        
        NSLog("[Event] \(event.rawValue) \(params ?? [:])")
    }
    
    func log(property: AppState.FirebaseState.Property) {
        
        var value = ""
        
        if property.first {
            if UserDefaults.standard.string(forKey: property.rawValue) != nil {
                value = UserDefaults.standard.string(forKey: property.rawValue)!
            } else {
                UserDefaults.standard.set(Locale.current.regionCode ?? "us", forKey: property.rawValue)
                value = Locale.current.regionCode ?? "us"
            }
        }
#if DEBUG
#else
        Analytics.setUserProperty(value, forName: property.rawValue)
#endif
        NSLog("[Property] \(property.rawValue) \(value)")
    }
}
