//
//  TabView.swift
//  WebBrowser
//
//  Created by yangjian on 2023/6/19.
//

import SwiftUI

struct TabView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var store: AppStore
    let colums:[GridItem] = [GridItem(.flexible()), GridItem(.flexible())]
    var count: Int {
        store.state.home.browsers.count
    }
    var isSelect: Bool {
        return store.state.home.browser.isSelect
    }
    
    var body: some View {
        VStack{
            ScrollView{
                LazyVGrid(columns: colums) {
                    ForEach(store.state.home.browsers, id: \.self) { browser in
                        Button {
                            select(browser)
                        } label: {
                            VStack{
                                HStack{
                                    Spacer()
                                    if count != 1 {
                                        Button {
                                            delete(browser)
                                        } label: {
                                            Image("tab_close")
                                        }
                                    }
                                }
                                Image("launch_icon").padding(.vertical, 40)
                                let url = browser.webView.url?.absoluteString ?? "Navigation"
                                Text(url).lineLimit(1).font(.system(size: 12)).foregroundColor(.white).padding(.horizontal, 10)
                                if browser.isSelect {
                                    Text("CURRENT SELECTED").foregroundColor(.white).opacity(0)
                                }
                                HStack {
                                    Spacer()
                                }
                            }
                        }.padding(.bottom,20).background(Color("#1778FF").cornerRadius(8))
                    }
                }
                .padding(.all, 16)
                Spacer()
            }
            ZStack {
                HStack{
                    Spacer()
                    Button(action: back) {
                        Text("Back").foregroundColor(.black).padding(.trailing, 20).padding(.vertical, 15)
                    }
                }
                Button(action: new) {
                    Image("tab_add")
                }
            }
        }.onAppear{
            viewDidLoad()
        }
    }
}

extension TabView {
    func viewDidLoad() {
        store.dispatch(.event(.tabShow, nil))
    }
    func delete(_ browser: Browser) {
        store.dispatch(.browserDelete(browser))
        store.dispatch(.browser)
    }
    
    func select(_ browser: Browser) {
        dismiss()
        store.dispatch(.browserSelect(browser))
        store.dispatch(.browser)
    }
    
    func new() {
        dismiss()
        store.dispatch(.homeText(""))
        store.dispatch(.browserAdd)
        store.dispatch(.browser)
        store.dispatch(.event(.browserNew, ["bro": "tab"]))
    }
    
    func back() {
        dismiss()
    }
}

struct TabView_Previews: PreviewProvider {
    static var previews: some View {
        TabView().environmentObject(AppStore())
    }
}
