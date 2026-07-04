//
//  Data.swift
//  CounterGraph
//
//  Created by 上別縄祐也 on 2023/11/09.
//

import Foundation

class PersonalData: Identifiable, Codable {
    let value: Int
    let name: String
    /// 所属グループのID。未所属は nil。
    /// Codable の optional なので、groupId を持たない旧データも nil として読み込める（後方互換）。
    let groupId: String?

    init(value: Int, name: String, groupId: String? = nil) {
        self.value = value
        self.name = name
        self.groupId = groupId
    }
}
