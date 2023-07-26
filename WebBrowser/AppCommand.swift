//
//  AppCommand.swift
//  WebBrowser
//
//  Created by yangjian on 2023/6/19.
//

import Foundation
import UIKit
import Combine
import AppTrackingTransparency
import UniformTypeIdentifiers

protocol AppCommand {
    func execute(in store: AppStore)
}

class SubscriptionToken {
    var cancelable: AnyCancellable?
    func unseal() { cancelable = nil }
}

extension AnyCancellable {
    func seal(in token: SubscriptionToken) {
        token.cancelable = self
    }
}

func GetRootVC() -> UIViewController {
    if let scene = UIApplication.shared.connectedScenes.filter({$0 is UIWindowScene}).first as? UIWindowScene, let keyWindow = scene.keyWindow,  let rootVC = keyWindow.rootViewController {
            return rootVC
    }
    return UIViewController()
}

func getPresentVC(vc: UIViewController) -> UIViewController {
    if let  presentedVC = vc.presentedViewController {
        return getPresentVC(vc: presentedVC)
    } else {
        return vc
    }
}

struct AlertCommand: AppCommand {
    let message: String
    init(_ message: String) {
        self.message = message
    }
    func execute(in store: AppStore) {
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        GetRootVC().present(alert, animated: true)
        Task{
            if !Task.isCancelled {
                try await Task.sleep(nanoseconds: 2_000_000_000)
                await alert.dismiss(animated: true)
            }
        }
    }
}

struct AlertCleanViewCommand: AppCommand {
    func execute(in store: AppStore) {
        let root = GetRootVC()
        let vc = AlertCleanViewController {
            store.dispatch(.homePopCleanView)
            store.dispatch(.clean)
            store.dispatch(.adDisappear(.native))
        }
        vc.modalPresentationStyle = .overCurrentContext
        root.present(vc, animated: true)
    }
}


struct LaunchingCommand: AppCommand {
    func execute(in store: AppStore) {
        let token = SubscriptionToken()
        var progress = 0.0
        var duration = 15.0
        Timer.publish(every: 0.01, on: .main, in: .common).autoconnect().sink { _ in
            progress += 0.01 / duration
            if progress < 1.0 {
                store.dispatch(.launchProgress(progress))
            } else {
                token.unseal()
                store.dispatch(.adShow(.interstitial) { _ in
                    if store.state.launch.progress >= 0.9 {
                        store.dispatch(.appDiDlaunched)
                    }
                })
            }
            
            if progress > 0.3, store.state.ad.isLoaded(.interstitial) {
                duration = 0.1
            }
        }.seal(in: token)
        store.dispatch(.adLoad(.native))
        store.dispatch(.adLoad(.interstitial))
    }
}

struct BrowserCommand: AppCommand {
    func execute(in store: AppStore) {
        let webView = store.state.home.browser.webView

        let goback = webView.publisher(for: \.canGoBack).sink { canGoBack in
            store.dispatch(.homeCanGoBack(canGoBack))
        }
        
        let goForword = webView.publisher(for: \.canGoForward).sink { canGoForword in
            store.state.home.canGoForword = canGoForword
            store.dispatch(.homeCanGoForwod(canGoForword))
        }
        
        let isLoading = webView.publisher(for: \.isLoading).sink { isLoading in
            debugPrint("isloading \(isLoading)")
            store.dispatch(.homeIsLoading(isLoading))
        }
        
        var start = Date()
        let progress = webView.publisher(for: \.estimatedProgress).sink { progress in
            if progress == 0.1 {
                start = Date()
                store.dispatch(.event(.searchBegian, nil))
            }
            if progress == 1.0 {
                let time = Date().timeIntervalSince1970 - start.timeIntervalSince1970
                store.dispatch(.event(.searchSuccess, ["bro": "\(ceil(time))"]))
            }
            store.dispatch(.homeProgress(progress))
        }
        
        let isNavigation = webView.publisher(for: \.url).map{$0 == nil}.sink { isNavigation in
            store.dispatch(.homeIsNavigation(isNavigation))
        }
        
        let url = webView.publisher(for: \.url).compactMap{$0}.sink { url in
            store.dispatch(.homeText(url.absoluteString))
        }
        
        store.bags = [goback, goForword, progress, isLoading, isNavigation, url]
    }
}


struct CleanCommand: AppCommand {
    func execute(in store: AppStore) {
        var progress = 0.0
        var duration = 16.0
        let token = SubscriptionToken()
        Timer.publish(every: 0.01, on: .main, in: .common).autoconnect().sink { _ in
            progress += 0.01 / duration
            store.dispatch(.cleanDegress(progress * 360))
            
            if !store.state.root.appLaunced || store.state.root.appEnterbackground {
                token.unseal()
                appCleaned(in: store, isBackground: true)
                return
            }
            if progress > duration {
                token.unseal()
                store.dispatch(.adShow(.interstitial) { _ in
                    appCleaned(in: store, isBackground: false)
                })
            }
            if progress > 0.2, store.state.ad.isLoaded(.interstitial) {
                duration = 0.1
            }
        }.seal(in: token)
        store.dispatch(.adLoad(.interstitial))
    }
    
    func appCleaned(in store: AppStore, isBackground: Bool) {
        store.dispatch(.cleanDismiss)
        store.dispatch(.browserClean)
        store.dispatch(.browser)
        store.dispatch(.event(.cleanAnimationCompletion, nil))
        if !isBackground {
            store.dispatch(.adLoad(.native))
            store.dispatch(.adLoad(.interstitial))
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            if store.state.root.appLaunced {
                store.dispatch(.alert("Cleaned"))
                store.dispatch(.event(.cleanCompletionAlertShow, ["bro": "2"]))
            }
        }
    }
}

struct ShareCommand: AppCommand {
    func execute(in store: AppStore) {
        let url = store.state.home.browser.webView.url?.absoluteString ?? "https://itunes.apple.com/cn/app/id6450499626"
        let vc = UIActivityViewController(
           activityItems: [url],
           applicationActivities: nil)
        GetRootVC().present(vc, animated: true)
    }
}

struct CopyCommand: AppCommand {
    func execute(in store: AppStore) {
        UIPasteboard.general.setValue(store.state.home.text, forPasteboardType: UTType.plainText.identifier)
        store.dispatch(.alert("Copy Successful."))
    }
}

struct FirebaseCommand: AppCommand {
    let event: AppState.FirebaseState.Event?
    let parameter: [String:Any]?
    let property: AppState.FirebaseState.Property?
    let value: String?
    func execute(in store: AppStore) {
        if let event = event {
            store.state.firebase.item.log(event: event, params: parameter)
        }
        if let property = property {
            store.state.firebase.item.log(property: property)
        }
    }
}

struct DismissKeyboardCommand: AppCommand {
    func execute(in store: AppStore) {
        UIApplication.shared.resignFirstResponder()
    }
}

struct ATTCommand: AppCommand {
    func execute(in store: AppStore) {
        Task{
            if !Task.isCancelled {
                try await Task.sleep(nanoseconds: 2_000_000_000)
                await ATTrackingManager.requestTrackingAuthorization()
            }
        }
    }
}

struct DismissControllerCommand: AppCommand {
    func execute(in store: AppStore) {
        let vc = GetRootVC()
        if let presentedVC = vc.presentedViewController {
            if let p = presentedVC.presentedViewController {
                p.dismiss(animated: true) {
                    presentedVC.dismiss(animated: true)
                }
            } else {
                presentedVC.dismiss(animated: true)
            }
        }
    }
}
