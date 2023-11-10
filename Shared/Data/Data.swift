//
//  Data.swift
//  CounterGraph
//
//  Created by 上別縄祐也 on 2023/11/09.
//

import Foundation

class personalData: Identifiable {
    let id = UUID()
    let value: Int
    let name: String
    
    init(value: Int, name: String) {
        self.value = value
        self.name = name
    }
}
