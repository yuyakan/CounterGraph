//
//  AppOpenAd.swift
//  CounterGraph
//
//  Created by 上別縄祐也 on 2023/11/13.
//

import GoogleMobileAds

class Interstitial: NSObject, FullScreenContentDelegate, ObservableObject {
    @Published var interstitialAdLoaded: Bool = false

    var interstitialAd: InterstitialAd?

    private let adUnitID = "ca-app-pub-3940256099942544/4411468910"//テスト

    /// 開発中は広告を無効化する。DEBUGビルドでは true になり、広告の読み込み・表示を行わない。
    #if DEBUG
    private let isAdDisabled = true
    #else
    private let isAdDisabled = false
    #endif

    override init() {
        super.init()
    }

    // 読み込み
    func loadInterstitial() {
        if isAdDisabled { return }
        let request = Request()
        request.scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        Task { @MainActor in
            do {
                let ad = try await InterstitialAd.load(with: adUnitID, request: request)
                ad.fullScreenContentDelegate = self
                self.interstitialAd = ad
                self.interstitialAdLoaded = true
            } catch {
                print(error)
                self.interstitialAd = nil
                self.interstitialAdLoaded = false
            }
        }
    }

    // インタースティシャル広告の表示
    func presentInterstitial() {
        if isAdDisabled { return }
        guard let ad = interstitialAd else {
            self.interstitialAdLoaded = false
            self.loadInterstitial()
            return
        }
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        guard let root = windowScene?.keyWindow?.rootViewController else {
            self.interstitialAdLoaded = false
            return
        }
        ad.present(from: root)
        self.interstitialAdLoaded = false
    }

    // 失敗通知
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("インタースティシャル広告の表示に失敗しました")
        self.interstitialAdLoaded = false
        self.loadInterstitial()
    }

    // 表示通知
    func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("インタースティシャル広告を表示しました")
        self.interstitialAdLoaded = false
    }

    // クローズ通知
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("インタースティシャル広告を閉じました")
        self.interstitialAdLoaded = false
        // 次の広告を先読みする
        self.loadInterstitial()
    }
}
