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
        
        // 保存済みタイトルがあればそのまま表示する（ユーザーが意図的に空にした場合は空のまま）。
        // タイトルキー自体が無い旧データ等のときだけプレースホルダー文言を出す。
        if let title = UserDefaults.standard.string(forKey: "Title_file\(fileId)") {
            self.title = title
        } else {
            title = String(localized: "newData")
        }
    }
}
