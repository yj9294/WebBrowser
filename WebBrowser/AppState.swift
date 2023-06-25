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
}

extension AppState {
    struct RootState{
        var appEnterbackground: Bool = false
        var appLaunced: Bool = false
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

