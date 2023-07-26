//
//  SettingView.swift
//  WebBrowser
//
//  Created by yangjian on 2023/6/19.
//

import SwiftUI

struct SettingView: View {
    @Environment(\.openURL) private var openURL
    @EnvironmentObject var store: AppStore
    @State var offset: Double = -270
    var body: some View {
        VStack{
            HStack{
                VStack{
                    VStack(spacing: 14){
                        Image("setting_icon")
                        Image("setting_title")
                    }.padding(.top, 70)
                    HStack{
                        Button(action: newAction) {
                            VStack(spacing: 5){
                                Image("new")
                                Text("New")
                            }
                        }
                        Spacer()
                        Button(action: shareAction) {
                            VStack(spacing: 5){
                                Image("share")
                                Text("Share")
                            }
                        }
                        Spacer()
                        Button(action: copyAction) {
                            VStack(spacing: 5){
                                Image("copy")
                                Text("copy")
                            }
                        }
                    }.foregroundColor(Color("#333333")).font(.system(size: 14.0)).padding(.horizontal, 25).padding(.top, 50)
                    Divider().padding(.top, 20)
                    VStack(spacing: 0){
                        Button(action: rateAction) {
                            HStack{
                                Image("rate")
                                Text("Rate Us")
                                Spacer()
                            }
                        }.padding(.vertical, 20)
                        Button(action: termsAction) {
                            HStack{
                                Image("terms")
                                Text("Terms of Users")
                                Spacer()
                            }
                        }.padding(.vertical, 20)
                        Button(action: privacyAction) {
                            HStack{
                                Image("privacy")
                                Text("Privacy Policy")
                                Spacer()
                            }
                        }.padding(.vertical, 20)
                    }.padding(.leading, 28).foregroundColor(Color("#333333"))
                    Spacer()
                }.frame(width: 270).background(Color.white).offset(x: offset)
                Spacer()
            }
        }.background(Color("#000000").opacity(0.5).ignoresSafeArea().onTapGesture {
            dismiss()
        }).animation(.spring()).onAppear{
            offset = 0
        }
    }
}

extension SettingView {
    func newAction() {
        dismiss()
        store.dispatch(.homeText(""))
        store.dispatch(.browserAdd)
        store.dispatch(.browser)
        store.dispatch(.event(.browserNew, ["bro": "setting"]))
    }
    func shareAction() {
        dismiss()
        store.dispatch(.share)
        store.dispatch(.event(.shareClick, nil))
    }
    func copyAction() {
        dismiss()
        store.dispatch(.copy)
        store.dispatch(.event(.copyClick, nil))
    }
    func rateAction() {
        dismiss()
        if let url = URL(string: "https://itunes.apple.com/cn/app/id6450499626") {
            openURL(url)
        }
    }
    func termsAction() {
        dismiss()
        store.dispatch(.homePopTermsView)
        store.dispatch(.adDisappear(.native))
    }
    func privacyAction() {
        dismiss()
        store.dispatch(.homePopPrivacyView)
        store.dispatch(.adDisappear(.native))
    }
    func dismiss() {
        offset = -270
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            store.dispatch(.homeShowSetting(false))
        }
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView().environmentObject(AppStore())
    }
}
