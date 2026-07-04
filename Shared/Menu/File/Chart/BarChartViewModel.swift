//
//  BarChartViewModel.swift
//  CounterGraph
//
//  Created by 上別縄祐也 on 2023/11/09.
//

import Foundation
import SwiftUI

/// Swift Charts へ渡すための棒1本分のデータ。
struct BarEntry: Identifiable {
    let id: Int          // dataList 内の index
    let name: String
    let value: Int
    let color: Color
}

class BarChartViewModel: ObservableObject {
    @Published var name : String = String(localized: "Jack")
    @Published var value: Int = 100
    @Published var isShowAlert : Bool = false
    @Published var dataList: DataList
    
    enum AlertType {
        case maxData
    }
    private var alertType: AlertType
    
    init(fileId: String) {
        self.dataList = DataList(fileId: fileId)
        self.alertType = .maxData
    }

    /// UserDefaults から最新のデータを読み直す。
    /// 複数タブが別インスタンスを持つため、タブ表示時に呼んで他タブの変更を反映する。
    func reload() {
        dataList = DataList(fileId: dataList.fileId)
        objectWillChange.send()
    }
    
    func maxValue() -> CGFloat{
        return CGFloat(dataList.max())
    }
    
    func count() -> Int {
        return dataList.count()
    }

    /// Swift Charts 描画用のエントリ一覧。
    /// 色は円グラフと共通のパレットを index で割り当て、下のリストと棒を紐づける。
    /// id は常に dataList 内の元 index を保持するため、ソートしてもカウント操作は正しい項目に効く。
    func entries(sortedBy order: ChartSortOrder = .entry) -> [BarEntry] {
        let palette = PieChartViewModel.defaultColors
        let base = (0..<dataList.count()).map { index in
            BarEntry(id: index,
                     name: dataList.name(index: index),
                     value: dataList.value(index: index),
                     color: palette[index % palette.count])
        }
        switch order {
        case .entry:      return base
        case .descending: return base.sorted { $0.value > $1.value }
        case .ascending:  return base.sorted { $0.value < $1.value }
        }
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

    /// 指定indexの名前を変更する。空文字は無視する。
    func updateName(index: Int, name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        dataList.updateName(index: index, name: trimmed)
        objectWillChange.send()
    }

    /// 指定indexの値を変更する。
    func updateValue(index: Int, value: Int) {
        dataList.updateValue(index: index, value: value)
        objectWillChange.send()
    }
    
    func addData() {
        if dataList.count() >= DataList.maxDataCount {
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
