//
//  MenuViewModel.swift
//  CounterGraph
//
//  Created by 上別縄祐也 on 2023/11/11.
//

import Foundation

class MenuViewModel: ObservableObject {
    @Published var refresh = false
     
    func titleList() -> [String] {
        var titleList: [String] = []
        for index in 0..<5 {
            if let title = UserDefaults.standard.string(forKey: "Title_file\(String(index))") {
                titleList.append(title)
            } else {
                if index == 0 {
                    titleList.append(String(localized: "Result"))
                } else {
                    titleList.append(String(localized: "newData"))
                }
            }
        }
        return titleList
    }
}
