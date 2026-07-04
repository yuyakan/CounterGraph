//
//  CountGroup.swift
//  CounterGraph
//
//  項目をまとめる「グループ」の定義と、fileId ごとの永続化ストア。
//  グループ合計をグループ色で表示するために使う。
//

import SwiftUI

/// 項目をまとめるグループ。名前と色を持つ。
struct CountGroup: Identifiable, Codable, Hashable {
    let id: String
    var name: String
    var color: Color

    init(id: String = UUID().uuidString, name: String, color: Color) {
        self.id = id
        self.name = name
        self.color = color
    }
}

/// グループ定義を fileId ごとに UserDefaults へ保存・管理する。
final class GroupStore: ObservableObject {
    /// グループに割り当てる既定色（順番に使う）。
    static let paletteColors: [Color] = [.red, .blue, .green, .orange, .purple, .pink, .teal, .indigo]

    @Published private(set) var groups: [CountGroup]

    private let fileId: String
    private var storageKey: String { "groups_file\(fileId)" }

    init(fileId: String) {
        self.fileId = fileId
        if let data = UserDefaults.standard.data(forKey: "groups_file\(fileId)"),
           let decoded = try? JSONDecoder().decode([CountGroup].self, from: data) {
            self.groups = decoded
        } else {
            self.groups = []
        }
    }

    /// id からグループを引く。
    func group(id: String?) -> CountGroup? {
        guard let id else { return nil }
        return groups.first { $0.id == id }
    }

    /// 新しいグループを追加して返す。色はパレットから未使用のものを優先する。
    @discardableResult
    func add(name: String) -> CountGroup {
        let usedColors = Set(groups.map { $0.color })
        let color = GroupStore.paletteColors.first { !usedColors.contains($0) }
            ?? GroupStore.paletteColors[groups.count % GroupStore.paletteColors.count]
        let group = CountGroup(name: name, color: color)
        groups.append(group)
        save()
        return group
    }

    /// グループ名を変更する。
    func rename(id: String, to name: String) {
        guard let index = groups.firstIndex(where: { $0.id == id }) else { return }
        groups[index].name = name
        save()
    }

    /// グループの色を変更する。
    func setColor(id: String, color: Color) {
        guard let index = groups.firstIndex(where: { $0.id == id }) else { return }
        groups[index].color = color
        save()
    }

    /// グループを削除する。
    func remove(id: String) {
        groups.removeAll { $0.id == id }
        save()
    }

    /// 最新の保存内容を読み直す（他タブでの変更反映用）。
    func reload() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([CountGroup].self, from: data) {
            groups = decoded
        } else {
            groups = []
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(groups) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}
