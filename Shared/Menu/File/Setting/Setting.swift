//
//  Setting.swift
//  CounterGraph
//
//  Created by 上別縄祐也 on 2023/11/10.
//

import Foundation
import SwiftUI

class Setting: ObservableObject{
    @Published var title: String = ""
    @Published var titleColor: Color = Color.brand
    @Published var textColor: Color = UITraitCollection.current.userInterfaceStyle == .dark ? Color.white : Color.black
    @Published var graphColor = Color.brand
    @Published var backColor = UITraitCollection.current.userInterfaceStyle == .dark ? Color.black : Color.white
    @Published var buttonColor = Color.brand
    let fileId: String
    
    init(fileId: String) {
        self.fileId = fileId
        
        if let title = UserDefaults.standard.string(forKey: "Title_file\(fileId)"){
            self.title = title
        } else {
            if fileId == "0" {
                self.title = String(localized: "Result")
            }
        }
        // 色はブランドカラー＋システム配色に統一したため、保存色の読み込みは行わない。
        // （旧バージョンで保存された紫などの色は無視し、常にブランドカラーを使う）
        save()
    }

    func save() {
        saveTitle()
    }
    
    private func saveTitle() {
        UserDefaults.standard.setValue(title, forKey: "Title_file\(fileId)")
    }
}
