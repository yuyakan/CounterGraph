//
//  MenuViewModel.swift
//  CounterGraph
//
//  Created by 上別縄祐也 on 2023/11/11.
//

import Foundation

class MenuViewModel: ObservableObject {
    @Published var refresh = false
    @Published var files: [File] = [File(fileId: "0")]

    init() {
        if !UserDefaults.standard.bool(forKey: "isSecondLaunched") {
            UserDefaults.standard.set(String(localized: "Result"), forKey: "Title_file0")
            save()
        }
        
        var files: [File] = []
        guard let fileIds: [String] = UserDefaults.standard.array(forKey: "fileIds") as? [String] else { return }
        for fileId in fileIds {
            files.append(File(fileId: fileId))
        }
        self.files = files
    }
    
    func rebuildFiles() {
        var files: [File] = []
        guard let fileIds: [String] = UserDefaults.standard.array(forKey: "fileIds") as? [String] else { return }
        for fileId in fileIds {
            files.append(File(fileId: fileId))
        }
        self.files = files
    }
    
    func save() {
        let fileIds = files.map { $0.id }
        UserDefaults.standard.set(fileIds, forKey: "fileIds")
    }
    
    func add() {
        files.append(File(fileId: UUID().uuidString))
        save()
    }

    /// 指定ファイルを複製する。タイトル・項目（名前と値）・円グラフの色をコピーし、
    /// 複製元の直後に挿入する。
    func duplicate(file: File) {
        guard let sourceIndex = files.firstIndex(of: file) else { return }
        let newId = UUID().uuidString
        let defaults = UserDefaults.standard

        // タイトルをコピー（「(コピー)」等は付けず元のまま。編集で変えられる）。
        if let title = defaults.string(forKey: "Title_file\(file.id)") {
            defaults.set(title, forKey: "Title_file\(newId)")
        }
        // 項目データ（data{index}_file{id}）をコピー。
        for index in 0..<DataList.maxDataCount {
            let key = "data\(index)_file\(file.id)"
            guard let value = defaults.object(forKey: key) else { break }
            defaults.set(value, forKey: "data\(index)_file\(newId)")
        }
        // 円グラフの色設定があればコピー。
        if let colors = defaults.object(forKey: "pieColors_file\(file.id)") {
            defaults.set(colors, forKey: "pieColors_file\(newId)")
        }
        // カウント幅があればコピー。
        let unit = defaults.integer(forKey: "CountUnit_file\(file.id)")
        if unit > 0 {
            defaults.set(unit, forKey: "CountUnit_file\(newId)")
        }

        files.insert(File(fileId: newId), at: sourceIndex + 1)
        save()
    }
     
    func moveRow(from source: IndexSet, to destination: Int) {
        files.move(fromOffsets: source, toOffset: destination)
        save()
    }
    
    func removeRow(offsets: IndexSet) {
        // 削除前に対象ファイルのID(UUID文字列)を確定させてから永続データを消す
        let removedIds = offsets.map { files[$0].id }
        files.remove(atOffsets: offsets)
        for fileId in removedIds {
            removeSetting(fileId: fileId)
            removeDataList(fileId: fileId)
            removePieColors(fileId: fileId)
        }
        save()
    }

    private func removeDataList(fileId: String) {
        for index in 0..<DataList.maxDataCount {
            UserDefaults.standard.removeObject(forKey: "data\(String(index))_file\(fileId)")
        }
    }

    private func removePieColors(fileId: String) {
        UserDefaults.standard.removeObject(forKey: "pieColors_file\(fileId)")
    }

    private func removeSetting(fileId: String){
        UserDefaults.standard.removeObject(forKey: "Title_file\(fileId)")
        UserDefaults.standard.removeObject(forKey: "titleColor_file\(fileId)")
        UserDefaults.standard.removeObject(forKey: "textColor_file\(fileId)")
        UserDefaults.standard.removeObject(forKey: "graphColor_file\(fileId)")
        UserDefaults.standard.removeObject(forKey: "backColor_file\(fileId)")
        UserDefaults.standard.removeObject(forKey: "buttonColor_file\(fileId)")
    }
}
