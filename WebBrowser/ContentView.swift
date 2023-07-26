//
//  ContentView.swift
//  WebBrowser
//
//  Created by yangjian on 2023/6/19.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: AppStore
    var appEnterbackground: Bool {
        store.state.root.appEnterbackground
    }
    var appLaunched: Bool {
        store.state.root.appLaunced
    }
    var body: some View {
        VStack{
            if !appLaunched {
                LoadingView()
            } else {
                HomeView()
            }
        }.onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            viewWillEnterForeground()
        }.onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            viewDidEnterBackground()
        }.onReceive(NotificationCenter.default.publisher(for: .nativeAdLoadCompletion)) { noti in
            if let ad = noti.object as? GADNativeViewModel {
                loadCompletion(ad)
            }
        }
    }
}


extension ContentView {
    
    func viewWillEnterForeground() {
        store.dispatch(.dismissController)
        store.dispatch(.willEnterForground)
        store.dispatch(.appWilllaunching)
        store.dispatch(.event(.openHot, nil))
    }
    
    func viewDidEnterBackground() {
        store.dispatch(.adDisappear(.native))
        store.dispatch(.didEnterBackground)
    }
    
    func loadCompletion(_ ad: GADNativeViewModel) {
        store.dispatch(.adModel(ad))
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(AppStore())
    }
}
