//
//  AppOpenAd.swift
//  CounterGraph
//
//  Created by 上別縄祐也 on 2023/11/13.
//

import GoogleMobileAds

class Interstitial: NSObject, GADFullScreenContentDelegate, ObservableObject {
    @Published var interstitialAdLoaded: Bool = false
    
    var interstitialAd: GADInterstitialAd?

    override init() {
        super.init()
    }

    // 読み込み
    func loadInterstitial() {
        let request = GADRequest()
        request.scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let id = "ca-app-pub-3940256099942544/4411468910"//テスト
        GADInterstitialAd.load(withAdUnitID: id, request: request, completionHandler: { [self] ad, error in
            if let error = error {
                print(error)
                self.interstitialAdLoaded = false
                return
            }
            self.interstitialAdLoaded = true
            self.interstitialAd = ad
            self.interstitialAd?.fullScreenContentDelegate = self
        })
    }

    // インタースティシャル広告の表示
    func presentInterstitial() {
        let scenes = UIApplication.shared.connectedScenes
        let windowScenes = scenes.first as? UIWindowScene
        let root = windowScenes?.keyWindow?.rootViewController
        if let ad = interstitialAd {
            ad.present(fromRootViewController: root!)
            self.interstitialAdLoaded = false
        } else {
            self.interstitialAdLoaded = false
            self.loadInterstitial()
        }
    }
    // 失敗通知
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("インタースティシャル広告の表示に失敗しました")
        self.interstitialAdLoaded = false
        self.loadInterstitial()
    }

    // 表示通知
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("インタースティシャル広告を表示しました")
        self.interstitialAdLoaded = false
    }

    // クローズ通知
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("インタースティシャル広告を閉じました")
        self.interstitialAdLoaded = false
    }
}
