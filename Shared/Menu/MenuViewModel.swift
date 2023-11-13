//
//  MenuViewModel.swift
//  CounterGraph
//
//  Created by 上別縄祐也 on 2023/11/11.
//

import Foundation

class MenuViewModel: ObservableObject {
    @Published var refresh = false
    @Published var files: [File] = [File(fileId: 0), File(fileId: 1), File(fileId: 2), File(fileId: 3), File(fileId: 4)]
    
    init() {
        if !UserDefaults.standard.bool(forKey: "isSecondLaunched") {
            UserDefaults.standard.set(String(localized: "Result"), forKey: "Title_file0")
            save()
        }
        
        var files: [File] = []
        guard let fileIds: [Int] = UserDefaults.standard.array(forKey: "fileIds") as? [Int] else { return }
        for fileId in fileIds {
            files.append(File(fileId: fileId))
        }
        self.files = files
    }
    
    func rebuildFiles() {
        var files: [File] = []
        guard let fileIds: [Int] = UserDefaults.standard.array(forKey: "fileIds") as? [Int] else { return }
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
//        files.append(File(fileId: <#T##Int#>))
    }
     
    func moveRow(from source: IndexSet, to destination: Int) {
        files.move(fromOffsets: source, toOffset: destination)
        save()
    }
    
    func removeRow(offsets: IndexSet) {
        files.remove(atOffsets: offsets)
        for index in offsets {
            removeSetting(fileId: index)
            removeDataList(fileId: index)
            removePieColors(fileId: index)
        }
        save()
    }

    private func removeDataList(fileId: Int) {
        for index in 0..<10 {
            UserDefaults.standard.removeObject(forKey: "data\(String(index))_file\(fileId)")
        }
    }
    
    private func removePieColors(fileId: Int) {
        UserDefaults.standard.removeObject(forKey: "buttonColor_file\(fileId)")
    }
    
    private func removeSetting(fileId: Int){
        UserDefaults.standard.removeObject(forKey: "Title_file\(fileId)")
        UserDefaults.standard.removeObject(forKey: "titleColor_file\(fileId)")
        UserDefaults.standard.removeObject(forKey: "textColor_file\(fileId)")
        UserDefaults.standard.removeObject(forKey: "graphColor_file\(fileId)")
        UserDefaults.standard.removeObject(forKey: "backColor_file\(fileId)")
        UserDefaults.standard.removeObject(forKey: "buttonColor_file\(fileId)")
    }
}
