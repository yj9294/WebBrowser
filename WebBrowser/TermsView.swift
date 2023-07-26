//
//  TermsView.swift
//  WebBrowser
//
//  Created by yangjian on 2023/6/19.
//

import SwiftUI

struct TermsView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        ZStack {
            VStack{
                Image("privacy_bg").ignoresSafeArea()
                Spacer()
            }
            ScrollView{
                Text("""
    Terms of use
    These terms apply to the use of this application, as well as to any other related agreements or legal relationships with the owner, in a legally binding manner. Users must read this document carefully.
    Use of the application
    1. you agree that we are not responsible for third party content that you access using our applications.
    2. You agree that we may discontinue some or all of our services at any time without prior notice to you.
    3. You may not use our applications for unauthorized commercial purposes or use our applications and services for illegal purposes.
    Update
    We will update these terms of use from time to time. We suggest you follow this page to learn about the updated status and content.
    Contact us
    If you have questions about our privacy policy or would like to suggest improvements to us, please contact us. You can contact us.
    z29333477@gmail.com
    """)
            }.padding().toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: back) {
                        Image("back")
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Terms of User")
                }
        }
        }
    }
}

extension TermsView {
    func back() {
        store.dispatch(.adLoad(.native))
        store.dispatch(.adLoad(.interstitial))
        dismiss()
    }
}

struct TermsView_Previews: PreviewProvider {
    static var previews: some View {
        TermsView()
    }
}
