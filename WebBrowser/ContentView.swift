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
        }
    }
}


extension ContentView {
    
    func viewWillEnterForeground() {
        store.dispatch(.willEnterForground)
        store.dispatch(.appWilllaunching)
        store.dispatch(.event(.openHot, nil))
    }
    
    func viewDidEnterBackground() {
        store.dispatch(.didEnterBackground)
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(AppStore())
    }
}
