//
//  File.swift
//  CounterGraph
//
//  Created by 上別縄祐也 on 2023/11/09.
//

import Foundation

struct DataList {
    let fileId: Int
    private var dataList: [PersonalData] = []
    
    init(fileId: Int) {
        self.fileId = fileId
        
        if (UserDefaults.standard.object(forKey: "data0_file\(String(fileId))") != nil) {
            createDataList(fileId: fileId)
        } else {
            if (fileId == 0) && !UserDefaults.standard.bool(forKey: "isSecondLaunched") {
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
    
    private mutating func createDataList(fileId: Int) {
        for index in 0..<10 {
            guard let personalData = UserDefaults.standard.object(forKey: "data\(String(index))_file\(String(fileId))") as? Data else {
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
            UserDefaults.standard.set(encodedData, forKey: "data\(String(index))_file\(String(fileId))" )
        }
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
        dataList[index] = PersonalData(value: newValue, name: newName)
        save(dataList: dataList)
    }
    
    mutating func minus(index: Int, value: Int) {
        let newValue = dataList[index].value - value
        let newName = dataList[index].name
        dataList[index] = PersonalData(value: newValue, name: newName)
        save(dataList: dataList)
    }
    
    mutating func add(value: Int, name: String) {
        dataList.append(PersonalData(value: value, name: name))
        save(dataList: dataList)
    }
    
    mutating func removeData(index: Int) {
        dataList.remove(at: index)
        for index in dataList.count..<10 {
            UserDefaults.standard.removeObject(forKey: "data\(index)_file\(String(fileId))")
        }
        save(dataList: dataList)
    }
}
