//
//  AppAction.swift
//  WebBrowser
//
//  Created by yangjian on 2023/6/19.
//

import Foundation

enum AppAction {
    case alert(String)
    case dismissKeyborad
    case att
    
    case willEnterForground
    case didEnterBackground
    case appWilllaunching
    case appDiDlaunched
    
    case launchProgress(Double)
    
    case homeCanGoForwod(Bool)
    case homeCanGoBack(Bool)
    case homeProgress(Double)
    case homeIsLoading(Bool)
    case homeIsNavigation(Bool)
    case homeText(String)
    
    case browser
    case browserLoad(String)
    case browserStopSearch
    case browserGoBack
    case browserGoForword
    
    case homeShowCleanAlert(Bool)
    case homeShowSetting(Bool)
    case homePopTabView
    case homePopCleanView
    case homePopPrivacyView
    case homePopTermsView
    
    case browserSelect(Browser)
    case browserDelete(Browser)
    case browserClean
    case browserAdd
    
    case cleanDegress(Double)
    case clean
    case cleanDismiss
    
    case share
    case copy
    
    case event(AppState.FirebaseState.Event, [String:Any]?)
    case property(AppState.FirebaseState.Property, String?)
}
