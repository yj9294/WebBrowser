//
//  GADCommand.swift
//  WebBrowser
//
//  Created by yangjian on 2023/6/26.
//


import Foundation
import GoogleMobileAds
import Firebase

struct GADRemoteConfigCommand: AppCommand {
    func execute(in store: AppStore) {
        // 获取本地配置
        if store.state.ad.config == nil {
            let path = Bundle.main.path(forResource: "admob", ofType: "json")
            let url = URL(fileURLWithPath: path!)
            do {
                let data = try Data(contentsOf: url)
                let config = try JSONDecoder().decode(GADConfig.self, from: data)
                store.dispatch(.adUpdateConfig(config))
                NSLog("[Config] Read local ad config success.")
            } catch let error {
                NSLog("[Config] Read local ad config fail.\(error.localizedDescription)")
            }
        }
        
        /// 远程配置
        let remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        remoteConfig.configSettings = settings
        remoteConfig.fetch { [weak remoteConfig] (status, error) -> Void in
            if status == .success {
                NSLog("[Config] Config fetcher! ✅")
                remoteConfig?.activate(completion: { _, _ in
                    let keys = remoteConfig?.allKeys(from: .remote)
                    NSLog("[Config] config params = \(keys ?? [])")
                    if let remoteAd = remoteConfig?.configValue(forKey: "adConfig").stringValue {
                        // base64 的remote 需要解码
                        let data = Data(base64Encoded: remoteAd) ?? Data()
                        if let remoteADConfig = try? JSONDecoder().decode(GADConfig.self, from: data) {
                            // 需要在主线程
                            DispatchQueue.main.async {
                                store.dispatch(.adUpdateConfig(remoteADConfig))
                            }
                        } else {
                            NSLog("[Config] Config config 'ad_config' is nil or config not json.")
                        }
                    }
                })
            } else {
                NSLog("[Config] config not fetcher, error = \(error?.localizedDescription ?? "")")
            }
        }
        
        /// 广告配置是否是当天的
        if store.state.ad.limit == nil || store.state.ad.limit?.date.isToday != true {
            store.state.ad.limit = GADLimit(showTimes: 0, clickTimes: 0, date: Date())
        }
    }
}

struct GADUpdateLimitCommand: AppCommand {
    
    let status: GADLimit.Status
    
    init(_ status: GADLimit.Status) {
        self.status = status
    }
    
    func execute(in store: AppStore) {
        if store.state.ad.isLimited(in: store) {
            NSLog("[AD] 用戶超限制。")
            store.dispatch(.adClean(.interstitial))
            store.dispatch(.adClean(.native))
            store.dispatch(.adDisappear(.native))
            return
        }

        if status == .show {
            let showTime = store.state.ad.limit?.showTimes ?? 0
            store.state.ad.limit?.showTimes = showTime + 1
            NSLog("[AD] [LIMIT] showTime: \(showTime+1) total: \(store.state.ad.config?.showTimes ?? 0)")
        } else  if status == .click {
            let clickTime = store.state.ad.limit?.clickTimes ?? 0
            store.state.ad.limit?.clickTimes = clickTime + 1
            NSLog("[AD] [LIMIT] clickTime: \(clickTime+1) total: \(store.state.ad.config?.clickTimes ?? 0)")
        }
    }
    
}

struct GADAppearCommand: AppCommand {
    let postion: GADPosition
    
    init(_ postion: GADPosition) {
        self.postion = postion
    }
    
    func execute(in store: AppStore) {
        store.state.ad.ads.filter {
            $0.position == postion
        }.first?.display()
    }
}

struct GADDisappearCommand: AppCommand {
    let position: GADPosition
    
    init(_ position: GADPosition) {
        self.position = position
    }
    
    func execute(in store: AppStore) {
        store.state.ad.ads.filter{
            $0.position == position
        }.first?.closeDisplay()
        
        if position == .native {
            store.dispatch(.adModel(.None))
        }
    }
}

struct GADCleanCommand: AppCommand {
    let position: GADPosition
    
    init(_ position: GADPosition) {
        self.position = position
    }
    
    func execute(in store: AppStore) {
        let loadAD = store.state.ad.ads.filter{
            $0.position == position
        }.first
        loadAD?.clean()
    }
}

struct GADLoadCommand: AppCommand {
    
    let position: GADPosition
    
    let p: GADPosition.Position
    
    var completion: ((GADNativeViewModel)->Void)? = nil
    
    init(_ position: GADPosition, _ p: GADPosition.Position, _ completion: ((GADNativeViewModel)->Void)? = nil) {
        self.position = position
        self.p = p
        self.completion = completion
    }
    
    func execute(in store: AppStore) {
        let ads = store.state.ad.ads.filter{
            $0.position == position
        }
        if let ad = ads.first {
            // 插屏直接一步加载
            if position == .interstitial {
                ad.beginAddWaterFall(callback: { isSuccess in
                    self.completion?(.None)
                }, in: store)
            } else if position == .native{
                // 原生广告需要同步显示
                ad.beginAddWaterFall(callback: { isSuccess in
                    if isSuccess {
                        store.dispatch(.adShow(self.position, self.p, completion))
                    }
                }, in: store)
            }
        }
    }
}

struct GADShowCommand: AppCommand {
    let position: GADPosition
    let p: GADPosition.Position
    var completion: ((GADNativeViewModel)->Void)? = nil
    
    init(_ position: GADPosition, _ p: GADPosition.Position = .home, _ completion: ((GADNativeViewModel)->Void)? = nil) {
        self.position = position
        self.p = p
        self.completion = completion
    }
    
    func execute(in store: AppStore) {
        
        // 超限需要清空广告
        if store.state.ad.isLimited(in: store) {
            store.dispatch(.adClean(.interstitial))
            store.dispatch(.adClean(.native))
            store.dispatch(.adDisappear(.native))
        }
        let loadAD = store.state.ad.ads.filter {
            $0.position == position
        }.first
        switch position {
        case .interstitial:
            /// 有廣告
            if let ad = loadAD?.loadedArray.first as? GADBaseModel.GADInterstitialModel, !store.state.ad.isLimited(in: store) {
                ad.impressionHandler = {
                    store.dispatch(.adUpdateLimit(.show))
                    store.dispatch(.adAppear(position))
                    store.dispatch(.adLoad(position))
                }
                ad.clickHandler = {
                    if !store.state.ad.isLimited(in: store) {
                        store.dispatch(.adUpdateLimit(.click))
                        if store.state.ad.isLimited(in: store) {
                            NSLog("[ad] 广告超限 点击无效")
                        }
                    } else {
                        NSLog("[ad] 广告超限 点击无效")
                    }
                }
                ad.closeHandler = {
                    completion?(.None)
                    store.dispatch(.adDisappear(position))
                }
                ad.present()
            } else {
                completion?(.None)
            }
            
        case .native:
            if let ad = loadAD?.loadedArray.first as? GADBaseModel.GADNativeModel, !store.state.ad.isLimited(in: store) {
                /// 预加载回来数据 当时已经有显示数据了
                if loadAD?.isDisplay == true {
                    return
                }
                ad.nativeAd?.unregisterAdView()
                ad.nativeAd?.delegate = ad
                ad.impressionHandler = {
                    store.dispatch(.adNativeImpressionDate(p))
                    store.dispatch(.adUpdateLimit(.show))
                    store.dispatch(.adAppear(position))
                    store.dispatch(.adLoad(position))
                }
                ad.clickHandler = {
                    store.dispatch(.adUpdateLimit(.click))
                }
                // 10秒间隔
                if let date = store.state.ad.impressionDate[p], Date().timeIntervalSince1970 - date.timeIntervalSince1970  < 10 {
                    NSLog("[ad] 刷新或数据加载间隔 10s postion: \(p)")
                    store.dispatch(.adModel(.None))
                    completion?(.None)
                    NotificationCenter.default.post(name: .nativeAdLoadCompletion, object: GADNativeViewModel.None)
                    return
                }
                
                let adViewModel = GADNativeViewModel(ad:ad, view: UINativeAdView())
                completion?(adViewModel)
                /// 异步加载 回调是nil的情况使用通知
                NotificationCenter.default.post(name: .nativeAdLoadCompletion, object: adViewModel)
            } else {
                /// 预加载回来数据 当时已经有显示数据了 并且没超过限制
                if loadAD?.isDisplay == true, !store.state.ad.isLimited(in: store) {
                    return
                }
                completion?(.None)
                store.dispatch(.adModel(.None))
            }
        }
    }
    
    
    func requestAtt() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            
        }
    }
}

extension Notification.Name {
    static let nativeAdLoadCompletion = Notification.Name(rawValue: "nativeAdLoadCompletion")
}
