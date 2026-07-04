//
//  File.swift
//  CounterGraph
//
//  Created by 上別縄祐也 on 2023/11/09.
//

import Foundation

struct DataList {
    /// 1ファイルあたりに保持できるデータの最大件数
    static let maxDataCount = 10

    let fileId: String
    private var dataList: [PersonalData] = []
    
    init(fileId: String) {
        self.fileId = fileId
        
        if (UserDefaults.standard.object(forKey: "data0_file\(String(fileId))") != nil) {
            createDataList(fileId: fileId)
        } else {
            if (fileId == "0") && !UserDefaults.standard.bool(forKey: "isSecondLaunched") {
                UserDefaults.standard.set(true, forKey: "isSecondLaunched")
                self.dataList = [
                    PersonalData(value: 80, name: String(localized: "Ann")),
                    PersonalData(value: 230, name: String(localized: "Tom")),
                    PersonalData(value: 500, name: String(localized: "Bob")),
                    PersonalData(value: 320, name: String(localized: "Casey")),
                    PersonalData(value: 120, name: String(localized: "Brian"))
                ]
            }
            save(dataList: dataList)
        }
    }
    
    private mutating func createDataList(fileId: String) {
        for index in 0..<DataList.maxDataCount {
            guard let personalData = UserDefaults.standard.object(forKey: "data\(String(index))_file\(fileId)") as? Data else {
                break
            }
            appendData(personalData: personalData)
        }
    }
    
    private mutating func appendData(personalData: Data) {
        let decoder = JSONDecoder()
        if let personalData = try? decoder.decode(PersonalData.self, from: personalData) {
            dataList.append(personalData)
        }
    }
    
    private func save(dataList: [PersonalData]) {
        let encoder =  JSONEncoder ()
        for index in 0..<dataList.count {
            guard let encodedData = try? encoder.encode(dataList[index]) else { break }
            UserDefaults.standard.set(encodedData, forKey: "data\(String(index))_file\(fileId)" )
        }
    }
    
    func max() -> Int {
        return dataList.map { $0.value }.max() ?? 0
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

    func groupId(index: Int) -> String? {
        return dataList[index].groupId
    }

    func getRatio() -> [Double] {
        let sum = sum()
        return dataList.map {Double($0.value) / sum}
    }
    
    private func sum() -> Double {
        return Double(dataList.reduce(0, {sum, data in sum + data.value}))
    }
    
    mutating func plus(index: Int, value: Int) {
        let old = dataList[index]
        dataList[index] = PersonalData(value: old.value + value, name: old.name, groupId: old.groupId)
        save(dataList: dataList)
    }

    mutating func minus(index: Int, value: Int) {
        let old = dataList[index]
        dataList[index] = PersonalData(value: old.value - value, name: old.name, groupId: old.groupId)
        save(dataList: dataList)
    }

    mutating func add(value: Int, name: String) {
        dataList.append(PersonalData(value: value, name: name))
        save(dataList: dataList)
    }

    /// 指定indexの名前を変更する。
    mutating func updateName(index: Int, name: String) {
        guard dataList.indices.contains(index) else { return }
        let old = dataList[index]
        dataList[index] = PersonalData(value: old.value, name: name, groupId: old.groupId)
        save(dataList: dataList)
    }

    /// 指定indexの値を変更する。
    mutating func updateValue(index: Int, value: Int) {
        guard dataList.indices.contains(index) else { return }
        let old = dataList[index]
        dataList[index] = PersonalData(value: value, name: old.name, groupId: old.groupId)
        save(dataList: dataList)
    }

    /// 指定indexのグループを変更する（nil で未所属に戻す）。
    mutating func updateGroup(index: Int, groupId: String?) {
        guard dataList.indices.contains(index) else { return }
        let old = dataList[index]
        dataList[index] = PersonalData(value: old.value, name: old.name, groupId: groupId)
        save(dataList: dataList)
    }
    
    mutating func removeData(index: Int) {
        dataList.remove(at: index)
        for index in dataList.count..<DataList.maxDataCount {
            UserDefaults.standard.removeObject(forKey: "data\(index)_file\(fileId)")
        }
        save(dataList: dataList)
    }
}
