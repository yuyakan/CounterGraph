//
//  ReviewManager.swift
//  CounterGraph
//
//  標準のレビュー要求ダイアログの表示制御。
//  広告表示とは独立したタイミングで、`SKStoreReviewController` を呼び出す。
//

import SwiftUI
import StoreKit

#if canImport(UIKit)
import UIKit
#endif

@MainActor
final class ReviewManager: ObservableObject {
    private static let opportunityCountKey = "reviewOpportunityCount"

    private var defaults: UserDefaults { .standard }

    /// 通常タイミングを記録し、必要なら標準レビュー要求を送信する。
    /// 広告はメニュー画面では表示されない（詳細画面遷移時に表示される）ため、
    /// ここでは広告との優先制御は行わず、機会カウントのみで判定する。
    /// - Returns: システムのレビュー要求を送信したなら true。
    @discardableResult
    func recordOpportunityAndRequestReviewIfNeeded() -> Bool {
        let opportunityCount = defaults.integer(forKey: Self.opportunityCountKey) + 1
        print("[ReviewManager] opportunityCount=\(opportunityCount) shouldRequest=\(shouldRequestReview(at: opportunityCount))")

        guard shouldRequestReview(at: opportunityCount) else {
            defaults.set(opportunityCount, forKey: Self.opportunityCountKey)
            return false
        }
        let requested = requestSystemReview()
        print("[ReviewManager] requestSystemReview -> \(requested)")
        guard requested else {
            return false
        }
        defaults.set(opportunityCount, forKey: Self.opportunityCountKey)
        return true
    }

    private func shouldRequestReview(at opportunityCount: Int) -> Bool {
        opportunityCount == 3 || (opportunityCount >= 10 && opportunityCount % 10 == 0)
    }

    private func requestSystemReview() -> Bool {
#if canImport(UIKit)
        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }) else {
            return false
        }
        SKStoreReviewController.requestReview(in: scene)
        return true
#elseif os(macOS)
        SKStoreReviewController.requestReview()
        return true
#else
        return false
#endif
    }
}
