//
//  HomeView.swift
//  WebBrowser
//
//  Created by yangjian on 2023/6/19.
//

import SwiftUI
import IQKeyboardManagerSwift

struct HomeView: View {
    @EnvironmentObject var store: AppStore
    let columns:[GridItem] = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    let bottomColumns:[GridItem] = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    let datasource = AppState.HomeState.Item.allCases
    let bottomsource = AppState.HomeState.BottomItem.allCases
    var progress: Double {
        store.state.home.progress
    }
    var body: some View {
        // 界面跳转
        ZStack {
            NavigationView {
                // 防止键盘弹出View上升
                GeometryReader{ _ in
                    VStack{
                        ZStack{
                            Image("top").resizable().ignoresSafeArea()
                            HStack{
                                TextField("Seaech or enter address", text: $store.state.home.text).onSubmit {
                                    search()
                                }.padding(.leading, 20)
                                    .padding(.vertical, 18)
                                if store.state.home.isLoading {
                                    Button(action: stopSearch) {
                                        Image("tab_close")
                                    }.padding(.trailing, 14)
                                } else {
                                    Button(action: search) {
                                        Image("search")
                                    }.padding(.trailing, 14)
                                }
                            }.background(Color.white.cornerRadius(8)).padding(.horizontal, 20)
                                .padding(.top, 12)
                        }.frame(height: 120)
                        ProgressView(value: progress, total: 1.0).opacity(store.state.home.isLoading ? 1 : 0)
                        VStack{
                            if store.state.home.isNavigation {
                                Image("launch_icon")
                                LazyVGrid(columns: columns, spacing: 20){
                                    ForEach(datasource, id: \.self) { item in
                                        Button(action: {
                                            searchItem(item)
                                        }, label: {
                                            VStack{
                                                Image(item.icon)
                                                Text(item.title)
                                                    .foregroundColor(Color("#333333"))
                                                    .font(.system(size: 13.0))
                                            }
                                        })
                                    }
                                }.padding(.horizontal, 16).padding(.top, 40)
                                Spacer()
                                VStack{
                                    NativeView(model: store.state.root.adModel)
                                }.padding(.horizontal, 20).frame(height: 124)
                                Spacer()
                            } else if !store.state.home.isPopTabView {
                                WebView(webView: store.state.home.browser.webView)
                            }
                        }
                        NavigationLink(isActive: $store.state.home.isPopTabView) {
                            TabView().navigationBarBackButtonHidden()
                        } label: {
                            EmptyView()
                        }
                        NavigationLink(isActive: $store.state.home.isPopCleanView) {
                            CleanView().navigationBarBackButtonHidden()
                        } label: {
                            EmptyView()
                        }
                        NavigationLink(isActive: $store.state.home.isPopPrivacyView) {
                            PrivacyView().navigationBarBackButtonHidden()
                        } label: {
                            EmptyView()
                        }
                        NavigationLink(isActive: $store.state.home.isPopTermsView) {
                            TermsView().navigationBarBackButtonHidden()
                        } label: {
                            EmptyView()
                        }
                        Spacer()
                        LazyVGrid(columns: bottomColumns, spacing: 20){
                            ForEach(bottomsource, id: \.self) { item in
                                Button(action: {
                                    bottomItem(item)
                                }, label: {
                                    BottomItem(item: item)
                                })
                            }
                        }.padding(.horizontal, 16)
                    }.background(Color("#F1FAFF"))
                }
            }
            if store.state.home.isShowSetting {
                SettingView()
            }
        }.onAppear{
            viewDidLoad()
        }
    }
    
    struct BottomItem: View {
        @EnvironmentObject var store: AppStore
        let item: AppState.HomeState.BottomItem
        var count: Int {
            store.state.home.browsers.count
        }
        var body: some View {
            VStack{
                if item == .last, !store.state.home.canGoBack {
                    Image("\(item.icon)_1")
                } else  if item == .next, !store.state.home.canGoForword {
                    Image("\(item.icon)_1")
                } else if item == .tab {
                    ZStack{
                        Image(item.icon)
                        Text("\(count)").font(.system(size: 14.0)).foregroundColor(.black)
                    }
                } else {
                    Image(item.icon)
                }
            }.padding(.vertical, 16)
        }
    }
}

extension HomeView {
    
    func viewDidLoad() {
        store.dispatch(.dismissKeyborad)
        store.dispatch(.event(.homeShow, nil))
        store.dispatch(.att)
        IQKeyboardManager.shared.enable = true
    }
    
    func stopSearch() {
        store.dispatch(.browserStopSearch)
    }
    
    func search(){
        store.dispatch(.dismissKeyborad)
        store.dispatch(.homeProgress(0))
        let text = store.state.home.text
        if text.count == 0 {
            store.dispatch(.alert("Please enter your search content."))
            return
        }
        store.dispatch(.browserLoad(text))
        store.dispatch(.browser)
        store.dispatch(.event(.homeClickSearch, ["bro": text]))
    }
    
    func searchItem(_ item: AppState.HomeState.Item) {
        store.dispatch(.homeProgress(0))
        store.dispatch(.homeText(item.url))
        store.dispatch(.browserLoad(item.url))
        store.dispatch(.browser)
        store.dispatch(.event(.homeClickButton, ["bro": item.rawValue]))
    }
    
    func bottomItem(_ item: AppState.HomeState.BottomItem) {
        switch item {
        case .last:
            store.dispatch(.browserGoBack)
        case .next:
            store.dispatch(.browserGoForword)
        case .clean:
            store.dispatch(.event(.homeClickSearch, nil))
            store.dispatch(.homeShowCleanAlert(true))
        case .tab:
            store.dispatch(.adDisappear(.native))
            store.dispatch(.homePopTabView)
            store.dispatch(.adLoad(.native, .tab))
        case .setting:
            store.dispatch(.homeShowSetting(true))
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView().environmentObject(AppStore())
    }
}
