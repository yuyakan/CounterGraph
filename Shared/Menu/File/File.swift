//
//  File.swift
//  CounterGraph
//
//  Created by 上別縄祐也 on 2023/11/13.
//

import Foundation

struct File: Hashable {
    let id: String
    let title: String
    
    init(fileId: String) {
        self.id = fileId
        
        // 保存済みタイトルが空（新規作成直後など）の場合もメニューカードでは
        // プレースホルダー文言を表示する。
        if let title = UserDefaults.standard.string(forKey: "Title_file\(fileId)"),
           !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.title = title
        } else {
            title = String(localized: "newData")
        }
    }
}
