//
//  BarChartViewModel.swift
//  CounterGraph
//
//  Created by 上別縄祐也 on 2023/11/09.
//

import Foundation

class BarChartViewModel: ObservableObject {
    @Published var name : String = String(localized: "Jack")
    @Published var value: Int = 100
    @Published var alert : Bool = false
    @Published var dataList: DataList
    
    init() {
        self.dataList = DataList()
    }
    
    
    func maxValue() -> CGFloat{
        return CGFloat(dataList.max())
    }
    
    func count() -> Int {
        return dataList.count()
    }
    
    func value(index: Int) -> CGFloat {
        return CGFloat(dataList.value(index: index))
    }
    
    func name(index: Int) -> String {
        return dataList.name(index: index)
    }
    
    func plus(index: Int, value: Int) {
        dataList.plus(index: index, value: value)
    }
    
    func minus(index: Int, value: Int) {
        dataList.minus(index: index, value: value)
    }
    
    func addData() {
        if dataList.contains(name: name) {
            alert = true
            return
        }
        dataList.add(value: value, name: name)
    }
    
    func removeData(index: Int) {
        dataList.removeData(index: index)
    }
}
