//
//  CleanView.swift
//  WebBrowser
//
//  Created by yangjian on 2023/6/19.
//

import SwiftUI

struct CleanView: View {
    @EnvironmentObject var store: AppStore
    var degrees: Double {
        store.state.clean.degress
    }
    var body: some View {
        VStack{
            Spacer()
            ZStack{
                Image("clean_bg")
                Image("clean_animation").rotationEffect(.degrees(degrees))
            }
            Spacer()
        }.background(Image("launch_bg"))
    }
}

struct CleanView_Previews: PreviewProvider {
    static var previews: some View {
        CleanView().environmentObject(AppStore())
    }
}
