//
//  LoadingView.swift
//  WebBrowser
//
//  Created by yangjian on 2023/6/19.
//

import SwiftUI

struct LoadingView: View {
    @EnvironmentObject var store: AppStore
    var progress: Double {
        store.state.launch.progress
    }
    var body: some View {
        VStack(spacing: 16){
            Image("launch_icon").padding(.top, 150)
            Image("launch_title")
            Spacer()
            HStack{
                Spacer()
            }
            ProgressView(value: progress, total: 1.0).accentColor(.white).padding(.horizontal, 66).padding(.bottom, 100)
        }.background(.linearGradient(Gradient(colors: [Color("#33B0FF"), Color("#1778FF")]), startPoint: .topLeading, endPoint: .bottomTrailing))
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView().environmentObject(AppStore())
    }
}
