//
//  AppState.swift
//  WebBrowser
//
//  Created by yangjian on 2023/6/19.
//

import Foundation
import WebKit

struct AppState {
    var root = RootState()
    var launch = LaunchState()
    var home = HomeState()
    var clean = CleanState()
    var firebase = FirebaseState()
    var ad = GADState()
}

extension AppState {
    struct RootState{
        var appEnterbackground: Bool = false
        var appLaunced: Bool = false
        var adModel: GADNativeViewModel = .None
    }
}

extension AppState {
    struct LaunchState{
        var progress: Double = 0.0
    }
}

extension AppState {
    struct HomeState {
        var text: String = ""
        var isLoading: Bool = false
        var canGoBack: Bool = false
        var canGoForword: Bool = false
        var isNavigation: Bool = true
        var progress: Double = 0.0
        
        var isShowCleanAlert: Bool = false
        var isShowSetting: Bool = false
        var isPopTabView: Bool = false
        var isPopCleanView: Bool = false
        var isPopPrivacyView: Bool = false
        var isPopTermsView: Bool = false

        var browsers: [Browser] = [.navigation]
        var browser: Browser {
            browsers.filter {
                $0.isSelect
            }.first ?? .navigation
        }
        enum Item: String, CaseIterable {
            case facebook, google, youtube, twitter, instagram, amazon, tiktok, yahoo
            var title: String {
                return "\(self)".capitalized
            }
            var url: String {
                return "https://www.\(self).com"
            }
            var icon: String {
                return "\(self)"
            }
        }
        enum BottomItem: String, CaseIterable {
            case last, next, clean, tab, setting
            var icon: String {
                return "\(self)"
            }
        }
    }
}

extension AppState {
    struct CleanState {
        var degress: Double = 0.0// 0 ~ 360
    }
}

extension AppState {
    struct FirebaseState {
        
        var item: FirebaseItem = .default
        
        enum Property: String {
            /// 設備
            case local = "lightBro_borth"
            
            var first: Bool {
                switch self {
                case .local:
                    return true
                }
            }
        }
        
        enum Event: String {
            
            var first: Bool {
                switch self {
                case .open:
                    return true
                default:
                    return false
                }
            }
            
            case open = "webBro_lun"
            case openCold = "webBro_clod"
            case openHot = "webBro_hot"
            case homeShow = "webBro_impress"
            case homeClickButton = "webBro_nav"
            case homeClickSearch = "webBro_search"
            case homeClickClean = "webBro_clean"
            
            case cleanAnimationCompletion = "webBro_cleanDone"
            case cleanCompletionAlertShow = "webBro_cleanToast"
            case tabShow = "webBro_showTab"
            case browserNew = "webBro_clickTab"
            case shareClick = "webBro_share"
            case copyClick = "webBro_copy"
            case searchBegian = "webBro_requist"
            case searchSuccess = "webBro_load"
        }
    }

}

extension AppState {
    struct GADState {
        
        @UserDefault(key: "state.ad.config")
        var config: GADConfig?
       
        @UserDefault(key: "state.ad.limit")
        var limit: GADLimit?
        
        var impressionDate:[GADPosition.Position: Date] = [:]
        
        let ads:[GADLoadModel] = GADPosition.allCases.map { p in
            GADLoadModel(position: p)
        }
        
        func isLoaded(_ position: GADPosition) -> Bool {
            return self.ads.filter {
                $0.position == position
            }.first?.isLoaded == true
        }

        func isLimited(in store: AppStore) -> Bool {
            if limit?.date.isToday == true {
                if (store.state.ad.limit?.showTimes ?? 0) >= (store.state.ad.config?.showTimes ?? 0) || (store.state.ad.limit?.clickTimes ?? 0) >= (store.state.ad.config?.clickTimes ?? 0) {
                    return true
                }
            }
            return false
        }
    }
}

@propertyWrapper
struct UserDefault<T: Codable> {
    var value: T?
    let key: String
    init(key: String) {
        self.key = key
        self.value = UserDefaults.standard.getObject(T.self, forKey: key)
    }
    
    var wrappedValue: T? {
        set  {
            value = newValue
            UserDefaults.standard.setObject(value, forKey: key)
            UserDefaults.standard.synchronize()
        }
        
        get { value }
    }
}

extension UserDefaults {
    func setObject<T: Codable>(_ object: T?, forKey key: String) {
        let encoder = JSONEncoder()
        guard let object = object else {
            debugPrint("[US] object is nil.")
            self.removeObject(forKey: key)
            return
        }
        guard let encoded = try? encoder.encode(object) else {
            debugPrint("[US] encoding error.")
            return
        }
        self.setValue(encoded, forKey: key)
    }
    
    func getObject<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = self.data(forKey: key) else {
            debugPrint("[US] data is nil for \(key).")
            return nil
        }
        guard let object = try? JSONDecoder().decode(type, from: data) else {
            debugPrint("[US] decoding error.")
            return nil
        }
        return object
    }
}
