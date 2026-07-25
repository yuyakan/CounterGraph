//
//  ConsentManager.swift
//  CounterGraph
//
//  広告の同意フローを管理する。
//  1) UMP（User Messaging Platform）で同意情報を更新し、必要なら同意フォームを表示する。
//  2) その後 ATT（App Tracking Transparency）の許可を要求する。
//  3) 同意状態が整い次第、Google Mobile Ads SDK を初期化する。
//
//  UMP の同意結果に基づき、SDK が自動でパーソナライズ/非パーソナライズ広告を切り替える。
//  そのため npa などのパラメータをアプリ側で明示設定する必要はない。
//

import AppTrackingTransparency
import GoogleMobileAds
import UIKit
import UserMessagingPlatform

@MainActor
final class ConsentManager {
    /// SDK の二重初期化を防ぐフラグ。
    private var didStartAds = false

    /// 同意フローを起動する。アプリ起動時に一度だけ呼ぶ想定。
    /// UMP の同意情報更新 → （必要なら）同意フォーム表示 → ATT 要求 → AdMob 初期化 の順で進む。
    func gatherConsent() {
        let parameters = RequestParameters()
        // デバッグ時に地域や同意状態を強制したい場合は DebugSettings をここで設定する。
        // 例: EEA 相当のフォームを検証する場合は debugGeography を指定する。
        #if DEBUG
        let debugSettings = DebugSettings()
        debugSettings.geography = .EEA
        parameters.debugSettings = debugSettings
        #endif

        // 同意情報を最新化する。ネットワーク経由で地域や必要フォームを判定する。
        // コールバックはメインスレッドで呼ばれるため、MainActor 隔離の本体へ入る。
        ConsentInformation.shared.requestConsentInfoUpdate(with: parameters) { [weak self] error in
            MainActor.assumeIsolated {
                guard let self else { return }
                if let error {
                    // 同意情報の取得に失敗しても、前回までに canRequestAds が立っていれば広告を出せる。
                    print("UMP: 同意情報の更新に失敗しました: \(error.localizedDescription)")
                    self.continueAfterConsent()
                    return
                }

                // 必要な場合のみ同意フォームを読み込んで表示する。不要な地域では即完了する。
                ConsentForm.loadAndPresentIfRequired(from: Self.topViewController()) { [weak self] formError in
                    MainActor.assumeIsolated {
                        if let formError {
                            print("UMP: 同意フォームの表示に失敗しました: \(formError.localizedDescription)")
                        }
                        self?.continueAfterConsent()
                    }
                }
            }
        }
    }

    /// UMP のフローが終わったあとの共通処理。
    /// 広告が要求できる状態なら ATT を要求してから SDK を初期化する。
    private func continueAfterConsent() {
        guard ConsentInformation.shared.canRequestAds else {
            // ユーザーが同意しなかった等で広告を要求できない場合は初期化しない。
            print("UMP: 広告のリクエストが許可されていません。")
            return
        }
        requestTrackingAuthorizationThenStartAds()
    }

    /// ATT の許可を要求し、その結果にかかわらず SDK を初期化する。
    /// ATT はあくまで IDFA 取得の可否であり、拒否されても（非パーソナライズで）広告自体は配信できる。
    private func requestTrackingAuthorizationThenStartAds() {
        Task {
            // ステータスが未決定のときだけシステムのダイアログが表示される。
            _ = await ATTrackingManager.requestTrackingAuthorization()
            self.startAdsIfNeeded()
        }
    }

    /// Google Mobile Ads SDK を初期化する（未初期化のときのみ）。
    private func startAdsIfNeeded() {
        guard !didStartAds else { return }
        didStartAds = true
        MobileAds.shared.start(completionHandler: nil)
    }

    /// 同意フォーム表示の起点となる最前面の ViewController を返す。
    private static func topViewController() -> UIViewController? {
        let scene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive } ?? UIApplication.shared.connectedScenes.first as? UIWindowScene
        var top = scene?.keyWindow?.rootViewController
        while let presented = top?.presentedViewController {
            top = presented
        }
        return top
    }
}
