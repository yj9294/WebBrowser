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

func GetRootVC(vc: UIViewController) -> UIViewController {
    if let  presentedVC = vc.presentedViewController {
        return GetRootVC(vc: presentedVC)
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
        if let keyWindowScene = UIApplication.shared.connectedScenes.filter({$0 is UIWindowScene}).first as? UIWindowScene, let keyWindow = keyWindowScene.keyWindow, let rootVC = keyWindow.rootViewController {
            let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
            GetRootVC(vc: rootVC).present(alert, animated: true)
            Task{
                if !Task.isCancelled {
                    try await Task.sleep(nanoseconds: 2_000_000_000)
                    await alert.dismiss(animated: true)
                }
            }
        }
    }
}

struct AlertCleanViewCommand: AppCommand {
    func execute(in store: AppStore) {
        if let keyWindowScene = UIApplication.shared.connectedScenes.filter({$0 is UIWindowScene}).first as? UIWindowScene, let keyWindow = keyWindowScene.keyWindow, let rootVC = keyWindow.rootViewController {
            let root = GetRootVC(vc: rootVC)
            let vc = AlertCleanViewController {
                store.dispatch(.homePopCleanView)
                store.dispatch(.clean)
            }
            vc.modalPresentationStyle = .overCurrentContext
            root.present(vc, animated: true)
        }
    }
}


struct LaunchingCommand: AppCommand {
    func execute(in store: AppStore) {
        let token = SubscriptionToken()
        var progress = 0.0
        let duration = 2.65
        Timer.publish(every: 0.01, on: .main, in: .common).autoconnect().sink { _ in
            progress += 0.01 / duration
            if progress < 1.0 {
                store.dispatch(.launchProgress(progress))
            } else {
                token.unseal()
                store.dispatch(.appDiDlaunched)
            }
        }.seal(in: token)
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
        let duration = 2.0
        let token = SubscriptionToken()
        Timer.publish(every: 0.01, on: .main, in: .common).autoconnect().sink { _ in
            progress += 0.01 / duration
            store.dispatch(.cleanDegress(progress * 360))
            if progress > duration {
                token.unseal()
                store.dispatch(.cleanDismiss)
                store.dispatch(.browserClean)
                store.dispatch(.browser)
                store.dispatch(.event(.cleanAnimationCompletion, nil))
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                    store.dispatch(.alert("Cleaned"))
                    store.dispatch(.event(.cleanCompletionAlertShow, ["bro": "2"]))
                }
            }
        }.seal(in: token)
    }
}

struct ShareCommand: AppCommand {
    func execute(in store: AppStore) {
        let url = store.state.home.browser.webView.url?.absoluteString ?? "https://itunes.apple.com/cn/app/id6450499626"
        let vc = UIActivityViewController(
           activityItems: [url],
           applicationActivities: nil)
        if let keyWindowScene = UIApplication.shared.connectedScenes.filter({$0 is UIWindowScene}).first as? UIWindowScene, let keyWindow = keyWindowScene.keyWindow, let rootVC = keyWindow.rootViewController {
            GetRootVC(vc: rootVC).present(vc, animated: true)
        }
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
