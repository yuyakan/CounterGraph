//
//  NameTemplateStore.swift
//  CounterGraph
//
//  「よく使う項目名」をファイル横断で共有するテンプレートストア。
//  項目追加時にワンタップで名前を呼び出せるようにする。値は扱わない。
//

import SwiftUI

/// よく使う項目名の一覧を UserDefaults に保存・共有する。
final class NameTemplateStore: ObservableObject {
    private static let storageKey = "nameTemplates"
    /// 保持できる名前テンプレートの最大件数（多すぎると呼び出しが煩雑になるため）。
    private static let maxCount = 30

    @Published private(set) var names: [String]

    init() {
        self.names = UserDefaults.standard.stringArray(forKey: NameTemplateStore.storageKey) ?? []
    }

    /// 名前を登録する。空・重複は無視し、新しいものを先頭に置く。
    func add(_ name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        // 既存があれば取り除いてから先頭へ（最近使った順に並べる）。
        var updated = names.filter { $0 != trimmed }
        updated.insert(trimmed, at: 0)
        if updated.count > NameTemplateStore.maxCount {
            updated = Array(updated.prefix(NameTemplateStore.maxCount))
        }
        names = updated
        save()
    }

    /// 指定した名前をテンプレートから削除する。
    func remove(_ name: String) {
        names.removeAll { $0 == name }
        save()
    }

    private func save() {
        UserDefaults.standard.set(names, forKey: NameTemplateStore.storageKey)
    }
}
