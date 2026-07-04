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

    /// 広告の有効/無効。現在はデバッグ時も含め常に有効（テストIDのためテスト広告が表示される）。
    private let isAdDisabled = false

    /// 読み込み失敗時のリトライ回数（成功で0に戻す）。指数バックオフの算出に使う。
    private var retryCount = 0
    /// リトライ上限。これを超えたら次の loadInterstitial() 呼び出しまで再試行しない。
    private let maxRetryCount = 5
    /// 二重読み込みを防ぐフラグ。
    private var isLoading = false

    /// 広告が表示可能な状態か。
    var isReady: Bool { interstitialAd != nil }

    override init() {
        super.init()
    }

    // 読み込み
    func loadInterstitial() {
        if isAdDisabled { return }
        // 既にロード済み、または読み込み中なら何もしない。
        if interstitialAd != nil || isLoading { return }
        isLoading = true

        let request = Request()
        request.scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        Task { @MainActor in
            do {
                let ad = try await InterstitialAd.load(with: adUnitID, request: request)
                ad.fullScreenContentDelegate = self
                self.interstitialAd = ad
                self.interstitialAdLoaded = true
                self.isLoading = false
                self.retryCount = 0
            } catch {
                print(error)
                self.interstitialAd = nil
                self.interstitialAdLoaded = false
                self.isLoading = false
                // 読み込み失敗時は指数バックオフでリトライする。
                self.scheduleRetry()
            }
        }
    }

    /// 指数バックオフ（2,4,8,…秒, 上限あり）で読み込みを再試行する。
    private func scheduleRetry() {
        guard retryCount < maxRetryCount else { return }
        retryCount += 1
        let delay = pow(2.0, Double(retryCount))  // 2,4,8,16,32 秒
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            self.loadInterstitial()
        }
    }

    /// カウンターがしきい値に達していて、かつ広告が準備できていれば表示する。
    /// 広告が未ロードのときはカウントを消費せず、次の機会に持ち越して読み込みを仕込む。
    func presentIfReady(counter: AdCounter) {
        guard isReady else {
            // 表示機会を無駄にしないよう、カウントは消費せず読み込みだけ促す。
            loadInterstitial()
            return
        }
        guard counter.consumeIfReady() else { return }
        presentInterstitial()
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
        // InterstitialAd は使い捨て。表示したら参照を破棄し、閉じたあと次を読み込む。
        self.interstitialAd = nil
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
