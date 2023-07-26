//
//  PrivacyView.swift
//  WebBrowser
//
//  Created by yangjian on 2023/6/19.
//

import SwiftUI

struct PrivacyView: View {
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
    Privacy Policy

    Welcome to Web browser, a secure browser, Web browser is a completely free secure browser that provides a secure environment for the user's browsing experience.

    Our Privacy Policy explains how we use, share and protect information related to our Mobile Services,and your choices about the collection and use of your information.

    Your privacy is important to us, and we take the protection and security of user information very seriously and will treat any and all such information in accordance with our Privacy Statement. If you choose to continue using the Software, you are consenting to the use of your data in accordance with our Privacy Statement.

    If you do not accept the terms set forth in this browser, you may not use the Software. By downloading and/or using the Software, you agree to be bound by all of the terms and conditions set forth in this browser.

    What information will we collect

    In order to enhance your experience, we may collect some information from you, and the collected information will only be used for lawful purposes.

    When you download and use our software or services, we usually collect some standard information provided by your browser, such as: browser type, language preference, etc.

    This information is collected to better understand how you use our products and how we can optimize them.

    How we will use the information

    When we process personal data based on your consent, this means that you have given us express permission to do so.

    When we process personal data based on a legitimate interest, this means we have some use for the personal data, such as making sure a product works properly, etc., which is balanced against your right to privacy.

    In some cases, it is necessary for us to process your personal data to fulfill other obligations imposed by law, such as: detecting fraud, ensuring you are who you say you are, etc.

    How we share information

    We share your personal information in accordance with this Privacy Policy, and we are committed to protecting the privacy and security of your personal information.

    We may also share your personal information internally.

    Update

    We may modify or update this Privacy Policy from time to time and will provide you with other forms of notice of modification or update as appropriate, so please check it periodically. Your continued use of this browser following any modification to this Privacy Policy constitutes your acceptance of such modification.

    Contact us

    If you have any questions about this Privacy Policy, you may contact us using the information below.



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
                    Text("Privacy Policy")
                }
        }
        }
    }
}

extension PrivacyView {
    func back() {
        dismiss()
        store.dispatch(.adLoad(.native))
        store.dispatch(.adLoad(.interstitial))
    }
}

struct PrivacyView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyView()
    }
}
