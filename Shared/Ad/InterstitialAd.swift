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

    /// テスト広告を使うかどうかの切替フラグ。
    /// - DEBUG ビルド  : true（Google公式のテストID）。開発中の無効トラフィックを防ぐ。
    /// - Release ビルド: false（本番の広告ユニットID）。
    /// ⚠️ 本番IDのまま自分の端末で広告を表示・タップすると無効トラフィックになる恐れがある。
    /// リリース前の実機確認では AdMob でテストデバイス登録を行うこと。
    #if DEBUG
    static let useTestAd = true
    #else
    static let useTestAd = false
    #endif

    /// 実際に使う広告ユニットID。
    private var adUnitID: String {
        Interstitial.useTestAd
            ? "ca-app-pub-3940256099942544/4411468910" // テスト
            : "ca-app-pub-3155724310732667/4658363529" // 本番
    }

    /// 広告の有効/無効。常に有効。広告IDは useTestAd フラグで本番/テストを切り替える。
    private let isAdDisabled = false

    /// 読み込み失敗時のリトライ回数（成功で0に戻す）。指数バックオフの算出に使う。
    private var retryCount = 0
    /// リトライ上限。これを超えたら次の loadInterstitial() 呼び出しまで再試行しない。
    private let maxRetryCount = 5
    /// 二重読み込みを防ぐフラグ。
    private var isLoading = false

    /// 広告が表示可能な状態か。
    var isReady: Bool { interstitialAd != nil }

    /// 前回広告を表示した時刻。クールダウン判定に使う。
    private var lastPresentedAt: Date?
    /// 広告表示のクールダウン（秒）。一度表示したらこの時間は次の広告を出さない。
    private let cooldown: TimeInterval = 90

    /// クールダウン中か（前回表示から cooldown 秒未満）。
    private var isInCooldown: Bool {
        guard let last = lastPresentedAt else { return false }
        return Date().timeIntervalSince(last) < cooldown
    }

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
    /// review が未実施なら、1回目の表示タイミングでは広告の代わりにレビュー依頼を表示する。
    func presentIfReady(counter: AdCounter, review: ReviewManager) {
        // 前回表示から一定時間（cooldown）は次を出さない。
        // カウントは消費せず持ち越し、クールダウン明けの機会に表示できるようにする。
        guard !isInCooldown else { return }

        // 表示条件（カウントしきい値）を満たすか確認。満たさなければ何もしない。
        // ここでは消費せず、「広告 or レビュー」を確定してから消費する。
        guard counter.count >= AdCounter.threshold else { return }

        // 1回目の表示タイミングでは広告の代わりにレビュー依頼を出す。
        if review.requestReviewIfNeeded() {
            _ = counter.consumeIfReady()   // 表示機会を使ったのでカウントをリセット
            lastPresentedAt = Date()       // レビューも全画面のためクールダウン対象にする
            return
        }

        // 通常の広告表示。未ロードならカウントは消費せず読み込みだけ促す。
        guard isReady else {
            loadInterstitial()
            return
        }
        _ = counter.consumeIfReady()
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
        // 表示時刻を記録し、以後 cooldown 秒は次の広告を出さない。
        lastPresentedAt = Date()
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
