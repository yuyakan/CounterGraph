//
//  SetTemplateStore.swift
//  CounterGraph
//
//  項目セット（いつものメンバー）を丸ごとテンプレート化して保存・復元する。
//  値は保存せず名前のみを扱い、テンプレートから作成した項目は値0で始まる。
//

import Foundation

/// 項目セットのテンプレート。名前の一覧のみを保持する（値は復元しない）。
struct SetTemplate: Identifiable, Codable, Hashable {
    let id: String
    /// テンプレート名（保存元ファイルのタイトルを既定にする）。
    var title: String
    /// 項目名の一覧。
    var itemNames: [String]

    init(id: String = UUID().uuidString, title: String, itemNames: [String]) {
        self.id = id
        self.title = title
        self.itemNames = itemNames
    }
}

/// 項目セットテンプレートの保存・復元を担うストア。
final class SetTemplateStore: ObservableObject {
    private static let storageKey = "setTemplates"

    @Published private(set) var templates: [SetTemplate]

    init() {
        if let data = UserDefaults.standard.data(forKey: SetTemplateStore.storageKey),
           let decoded = try? JSONDecoder().decode([SetTemplate].self, from: data) {
            self.templates = decoded
        } else {
            self.templates = []
        }
    }

    /// 指定ファイルの現在の項目一覧をテンプレートとして保存する。
    /// 項目が無いファイルは保存しない。
    func saveTemplate(fromFileId fileId: String) {
        let dataList = DataList(fileId: fileId)
        let names = dataList.names()
        guard !names.isEmpty else { return }
        let title = UserDefaults.standard.string(forKey: "Title_file\(fileId)")
            ?? String(localized: "newData")
        templates.insert(SetTemplate(title: title, itemNames: names), at: 0)
        save()
    }

    /// テンプレートの内容を新規ファイルへ書き込む。値はすべて0で始める。
    /// タイトルもテンプレート名で初期化する。
    func apply(_ template: SetTemplate, toFileId fileId: String) {
        UserDefaults.standard.set(template.title, forKey: "Title_file\(fileId)")
        var dataList = DataList(fileId: fileId)
        for name in template.itemNames {
            dataList.add(value: 0, name: name)
        }
    }

    /// テンプレートを削除する。
    func remove(_ template: SetTemplate) {
        templates.removeAll { $0.id == template.id }
        save()
    }

    private func save() {
        if let data = try? JSONEncoder().encode(templates) {
            UserDefaults.standard.set(data, forKey: SetTemplateStore.storageKey)
        }
    }
}
