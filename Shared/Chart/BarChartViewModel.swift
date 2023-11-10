//
//  BarChartViewModel.swift
//  CounterGraph
//
//  Created by 上別縄祐也 on 2023/11/09.
//

import Foundation
import SwiftUI

class BarChartViewModel: ObservableObject {
    @Published var name : String = String(localized: "Jack")
    @Published var value: Int = 100
    @Published var isShowAlert : Bool = false
    @Published var dataList: DataList
    
    enum AlertType {
        case maxData
    }
    
    private var alertType: AlertType
    
    init() {
        self.dataList = DataList()
        self.alertType = .maxData
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
    
    func removeData(index: Int) {
        dataList.removeData(index: index)
    }
    
    func addData() {
        if dataList.count() > 9 {
            maxDataAlert()
            return
        }
        dataList.add(value: value, name: name)
    }
    
    private func maxDataAlert() {
        alertType = .maxData
        isShowAlert = true
    }
    
    func alert() -> Alert {
        switch alertType {
        case .maxData :
            return Alert(title: Text(LocalizedStringKey("maxAlertText")),
                         message: Text(LocalizedStringKey("maxAlertMessage")),
                         dismissButton: .default(Text("OK"),action: {self.isShowAlert = false}))
        }
    }
}
