//
//  Store.swift
//  WebBrowser
//
//  Created by yangjian on 2023/6/19.
//

import Foundation
import Combine

class AppStore: ObservableObject {
    @Published var state: AppState = AppState()
    var bags = [AnyCancellable]()
    init(){
        dispatch(.appWilllaunching)
        dispatch(.property(.local, nil))
        dispatch(.event(.open, nil))
        dispatch(.event(.openCold, nil))
    }
}

extension AppStore {
    func dispatch(_ action: AppAction) {
        debugPrint("[ACTION]: \(action)")
        let result = AppStore.reduce(state: state, action: action)
        state = result.0
        if let command = result.1 {
            command.execute(in: self)
        }
    }
}

extension AppStore{
    private static func reduce(state: AppState, action: AppAction) -> (AppState, AppCommand?) {
        var appState = state
        var appCommand: AppCommand? = nil
        switch action {
        case .alert(let message):
            appCommand = AlertCommand(message)
        case .dismissKeyborad:
            appCommand = DismissKeyboardCommand()
        case .att:
            appCommand = ATTCommand()
            
        case .willEnterForground:
            appState.root.appEnterbackground = false
        case .didEnterBackground:
            appState.root.appEnterbackground = true
        case .appWilllaunching:
            appState.root.appLaunced = false
            appCommand = LaunchingCommand()
        case .appDiDlaunched:
            appState.root.appLaunced = true
            
        case .launchProgress(let progress):
            appState.launch.progress = progress
            
        case .homeText(let text):
            appState.home.text = text
        case .homeIsLoading(let isLoading):
            appState.home.isLoading = isLoading
        case .homeIsNavigation(let isNavigation):
            appState.home.isNavigation = isNavigation
        case .homeCanGoBack(let canGoBack):
            appState.home.canGoBack = canGoBack
        case .homeCanGoForwod(let canGoForword):
            appState.home.canGoForword = canGoForword
        case .homeProgress(let progress):
            appState.home.progress = progress
            
        case .browser:
            appCommand = BrowserCommand()
        case .browserLoad(let text):
            appState.home.browser.load(text)
        case .browserStopSearch:
            appState.home.browser.stopLoad()
        case .browserGoBack:
            appState.home.browser.goBack()
        case .browserGoForword:
            appState.home.browser.goForword()
        case .homeShowCleanAlert(let isShow):
            appState.home.isShowCleanAlert = isShow
            appCommand = AlertCleanViewCommand()
        case .homeShowSetting(let isShow):
            appState.home.isShowSetting = isShow
            
        case .homePopTabView:
            appState.home.isPopTabView = true
        case .homePopCleanView:
            appState.home.isPopCleanView = true
        case .homePopPrivacyView:
            appState.home.isPopPrivacyView = true
        case .homePopTermsView:
            appState.home.isPopTermsView = true
            
        case .browserAdd:
            appState.home.browsers.forEach {
                $0.isSelect = false
            }
            appState.home.browsers.insert(.navigation, at: 0)
        case .browserSelect(let browser):
            appState.home.browsers.forEach {
                $0.isSelect = false
            }
            browser.isSelect = true
        case .browserClean:
            appState.home.browsers = [.navigation]
            
        case .browserDelete(let browser):
            if browser.isSelect {
                appState.home.browsers = appState.home.browsers.filter({
                    !$0.isSelect
                })
                appState.home.browsers.first?.isSelect = true
            } else {
                appState.home.browsers = appState.home.browsers.filter({
                    $0.webView != browser.webView
                })
            }
        case .cleanDegress(let degress):
            appState.clean.degress = degress
        case .clean:
            appCommand = CleanCommand()
        case .cleanDismiss:
            appState.home.isPopCleanView = false
            
        case .share:
            appCommand = ShareCommand()
        case .copy:
            appCommand = CopyCommand()
            
        case .event(let key, let parameters):
            appCommand = FirebaseCommand(event: key, parameter: parameters, property: nil, value: nil)
        case .property(let key, let value):
            appCommand = FirebaseCommand(event: nil, parameter: nil, property: key, value: value)

        }
        return (appState, appCommand)
    }
}
