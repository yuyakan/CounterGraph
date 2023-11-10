//
//  File.swift
//  CounterGraph
//
//  Created by 上別縄祐也 on 2023/11/09.
//

import Foundation

struct DataList {
    private var dataList: [personalData]
    
    init() {
        self.dataList = [
            personalData(value: 80, name: String(localized: "Ann")),
            personalData(value: 230, name: String(localized: "Tom")),
            personalData(value: 500, name: String(localized: "Bob")),
            personalData(value: 320, name: String(localized: "Casey")),
            personalData(value: 120, name: String(localized: "Brian"))
        ]
    }
    
    init(dataList: [personalData]) {
        self.dataList = dataList
    }
    
    
    func max() -> Int {
        return dataList.reduce(dataList[0].value, { Swift.max($0, $1.value) })
    }
    
    func count() -> Int {
        return dataList.count
    }
    
    func value(index: Int) -> Int {
        return dataList[index].value
    }
    
    func name(index: Int) -> String {
        return dataList[index].name
    }
    
    func names() -> [String] {
        return dataList.map { $0.name }
    }
    
    func contains(name: String) -> Bool {
        return dataList.contains { $0.name == name }
    }
    
    func getRatio() -> [Double] {
        let sum = sum()
        return dataList.map {Double($0.value) / sum}
    }
    
    private func sum() -> Double {
        return Double(dataList.reduce(0, {sum, data in sum + data.value}))
    }
    
    mutating func plus(index: Int, value: Int) {
        let newValue = dataList[index].value + value
        let newName = dataList[index].name
        dataList[index] = personalData(value: newValue, name: newName)
    }
    
    mutating func minus(index: Int, value: Int) {
        let newValue = dataList[index].value - value
        let newName = dataList[index].name
        dataList[index] = personalData(value: newValue, name: newName)
    }
    
    mutating func add(value: Int, name: String) {
        dataList.append(personalData(value: value, name: name))
    }
    
    mutating func removeData(index: Int) {
        dataList.remove(at: index)
    }
}
