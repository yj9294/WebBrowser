//
//  GADNativeView.swift
//  WebBrowser
//
//  Created by yangjian on 2023/6/26.
//

import Foundation
import SwiftUI
import GoogleMobileAds

class GADNativeViewModel: NSObject {
    let ad: GADBaseModel.GADNativeModel?
    let view: UINativeAdView
    init(ad: GADBaseModel.GADNativeModel? = nil, view: UINativeAdView) {
        self.ad = ad
        self.view = view
        self.view.refreshUI(ad: ad?.nativeAd)
    }
    
    static var None: GADNativeViewModel {
        GADNativeViewModel(view: UINativeAdView())
    }
}


struct NativeView: UIViewRepresentable {
    let model: GADNativeViewModel
    func makeUIView(context: UIViewRepresentableContext<NativeView>) -> UIView {
        return model.view
    }
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<NativeView>) {
        if let uiView = uiView as? UINativeAdView {
            uiView.refreshUI(ad: model.ad?.nativeAd)
        }
    }
}

class UINativeAdView: GADNativeAdView {

    init(){
        super.init(frame: UIScreen.main.bounds)
        setupUI()
        refreshUI(ad: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 暫未圖
    lazy var placeholderView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    lazy var adView: UIImageView = {
        let image = UIImageView(image: UIImage(named: "ad_tag"))
        return image
    }()
    
    lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .gray
        imageView.layer.cornerRadius = 2
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14.0, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()
    
    lazy var subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11.0)
        label.textColor = .white
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()
    
    lazy var installLabel: UIButton = {
        let label = UIButton()
        label.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.setTitleColor(UIColor.white, for: .normal)
        label.layer.cornerRadius = 20
        label.layer.masksToBounds = true
        return label
    }()
}

extension UINativeAdView {
    func setupUI() {
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
        
        addSubview(placeholderView)
        placeholderView.frame = self.bounds
        
        
        addSubview(iconImageView)
        iconImageView.frame = CGRectMake(16, 20, 44, 44)
        
        
        addSubview(titleLabel)
        let width = self.bounds.size.width - iconImageView.frame.maxX - 12 - 10 - 25 - 16
        titleLabel.frame = CGRectMake(iconImageView.frame.maxX + 8, 19, width, 15)

        
        addSubview(adView)
        adView.frame = CGRectMake(titleLabel.frame.maxX + 10, 19, 25, 14)
        
        addSubview(subTitleLabel)
        subTitleLabel.frame = CGRectMake(titleLabel.frame.minX, titleLabel.frame.maxY + 10, width + 25 + 10, 15)

        
        addSubview(installLabel)
        let w = self.bounds.size.width - 32
        installLabel.frame = CGRectMake(16, iconImageView.frame.maxY + 8, w, 36)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupUI()
    }
    
    func refreshUI(ad: GADNativeAd? = nil) {
        self.nativeAd = ad
        self.backgroundColor = .white
//        placeholderView.image = UIImage(named: "ad_placeholder")
        self.adView.image = UIImage(named: "ad_tag")
        self.installLabel.setTitleColor(.white, for: .normal)
        self.installLabel.backgroundColor = UIColor(named: "#187AFF")
        self.subTitleLabel.textColor = UIColor(named: "#858585")
        self.titleLabel.textColor = UIColor(named: "#525050")
        
        self.iconView = self.iconImageView
        self.headlineView = self.titleLabel
        self.bodyView = self.subTitleLabel
        self.callToActionView = self.installLabel
        self.installLabel.setTitle(ad?.callToAction, for: .normal)
        self.iconImageView.image = ad?.icon?.image
        self.titleLabel.text = ad?.headline
        self.subTitleLabel.text = ad?.body
        
        self.hiddenSubviews(hidden: self.nativeAd == nil)
        
        if ad == nil {
            self.placeholderView.isHidden = false
        } else {
            self.placeholderView.isHidden = true
        }
    }
    
    func hiddenSubviews(hidden: Bool) {
        self.iconImageView.isHidden = hidden
        self.titleLabel.isHidden = hidden
        self.subTitleLabel.isHidden = hidden
        self.installLabel.isHidden = hidden
        self.adView.isHidden = hidden
    }
}
