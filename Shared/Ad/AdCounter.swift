//
//  AdCounter.swift
//  CounterGraph
//
//  広告表示のための操作回数カウンター（アプリ全体で共通）。
//  詳細画面の編集「完了」・メニューの「追加」・「複製」を同じカウントで数え、
//  3回以上たまったら広告を表示し、表示後は0にリセットする。
//

import Foundation

final class AdCounter: ObservableObject {
    private static let storageKey = "adActionCount"
    /// 広告を表示する操作回数のしきい値。
    static let threshold = 3

    @Published private(set) var count: Int

    init() {
        self.count = UserDefaults.standard.integer(forKey: AdCounter.storageKey)
    }

    /// 対象操作を1回ぶん加算する。
    func increment() {
        count += 1
        save()
    }

    /// しきい値に達していれば true を返し、カウントを0にリセットする。
    /// 広告表示の可否判定に使う（呼んだ時点でリセットするので副作用に注意）。
    func consumeIfReady() -> Bool {
        guard count >= AdCounter.threshold else { return false }
        count = 0
        save()
        return true
    }

    private func save() {
        UserDefaults.standard.set(count, forKey: AdCounter.storageKey)
    }
}
