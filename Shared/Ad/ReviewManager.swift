//
//  ReviewManager.swift
//  CounterGraph
//
//  カスタムのレビュー依頼ダイアログの表示制御。
//  1回目の広告表示タイミングで、広告の代わりに一度だけレビュー依頼を表示する。
//

import SwiftUI
import UIKit

final class ReviewManager: ObservableObject {
    private static let requestedKey = "reviewRequested"
    /// App Store のアプリID。
    private static let appStoreID = "1611172252"

    /// レビュー依頼ダイアログを表示すべきか（ビュー側が監視して表示する）。
    @Published var showReviewDialog = false

    /// これまでにレビュー依頼を表示したことがあるか。
    private var hasRequested: Bool {
        UserDefaults.standard.bool(forKey: ReviewManager.requestedKey)
    }

    /// 広告表示の代わりにレビュー依頼を出すべきかを判定する。
    /// まだ一度も出していなければ true を返し、以後は出さないよう記録する。
    /// - Returns: レビュー依頼を出した（＝広告を出さない）なら true。
    func requestReviewIfNeeded() -> Bool {
        guard !hasRequested else { return false }
        UserDefaults.standard.set(true, forKey: ReviewManager.requestedKey)
        showReviewDialog = true
        return true
    }

    /// App Store のレビュー投稿ページを開く。
    func openAppStoreReview() {
        guard let url = URL(string: "https://apps.apple.com/app/id\(ReviewManager.appStoreID)?action=write-review") else { return }
        UIApplication.shared.open(url)
    }
}
