//
//  MenuViewModel.swift
//  CounterGraph
//
//  Created by 上別縄祐也 on 2023/11/11.
//

import Foundation

class MenuViewModel: ObservableObject {
    @Published var refresh = false
    @Published var files: [File] = [File(fileId: "0"), File(fileId: UUID().uuidString), File(fileId: UUID().uuidString), File(fileId: UUID().uuidString), File(fileId: UUID().uuidString)]
    
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
