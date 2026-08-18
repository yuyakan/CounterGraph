//
//  PieChartViewModel.swift
//  CounterGraph
//
//  Created by 上別縄祐也 on 2023/11/10.
//

import Foundation
import SwiftUI

/// Swift Charts(SectorMark) へ渡す扇形1つぶんのデータ。
struct SectorEntry: Identifiable {
    let id: Int          // dataList 内の index
    let name: String
    let value: Int
    let color: Color
    let percent: String
}

class PieChartViewModel: ObservableObject {
    @Published var colors: [Color]
    private var dataList: DataList

    /// 項目追加シート用の入力値（棒グラフと同じ挙動）。
    @Published var name: String = String(localized: "Jack")
    @Published var value: Int = 100
    @Published var isShowAlert: Bool = false

    enum AlertType {
        case maxData
    }
    private var alertType: AlertType = .maxData

    /// 凡例の既定色（データ件数の上限ぶん用意しておく）。
    static let defaultColors: [Color] = [.orange, .green, .blue, .red, .yellow, .pink, .purple, .mint, .indigo, .cyan]

    init(fileId: String) {
        self.dataList = DataList(fileId: fileId)

        let jsonDecoder = JSONDecoder()
        if let saved = UserDefaults.standard.object(forKey: "pieColors_file\(dataList.fileId)") as? Data,
           let pieColors = try? jsonDecoder.decode([Color].self, from: saved) {
            self.colors = pieColors
        } else {
            self.colors = PieChartViewModel.defaultColors
        }

        // 保存色が古く、データ件数より少ない場合に備えて不足ぶんを既定色で補う。
        // これがないと colors[index] が範囲外アクセスでクラッシュする。
        ensureColorCount(dataList.count())
    }

    /// UserDefaults から最新のデータを読み直す。タブ表示時に呼び他タブの変更を反映する。
    func reload() {
        dataList = DataList(fileId: dataList.fileId)
        ensureColorCount(dataList.count())
        objectWillChange.send()
    }

    /// colors の要素数が少なくとも `count` になるよう、不足ぶんを既定色で補完する。
    private func ensureColorCount(_ count: Int) {
        guard colors.count < count else { return }
        for index in colors.count..<count {
            colors.append(PieChartViewModel.defaultColors[index % PieChartViewModel.defaultColors.count])
        }
    }
    
    func save() {
        let jsonEncoder = JSONEncoder()
        guard let colors = try? jsonEncoder.encode(colors) else { return }
        UserDefaults.standard.set(colors, forKey: "pieColors_file\(dataList.fileId)")
    }
    
    func names() -> [String] {
        return dataList.names()
    }

    func percents() ->[String] {
        return dataList.getRatio().map { String(format: "%.1f", $0 * 100) + "%" }
    }

    /// Swift Charts(SectorMark) 描画用のエントリ一覧。
    /// id は元 index を保持する。
    func entries(sortedBy order: ChartSortOrder = .entry) -> [SectorEntry] {
        let percents = self.percents()
        let base = (0..<dataList.count()).map { index in
            SectorEntry(id: index,
                        name: dataList.name(index: index),
                        value: dataList.value(index: index),
                        color: index < colors.count ? colors[index] : PieChartViewModel.defaultColors[index % PieChartViewModel.defaultColors.count],
                        percent: index < percents.count ? percents[index] : "")
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
        objectWillChange.send()
    }

    func minus(index: Int, value: Int) {
        dataList.minus(index: index, value: value)
        objectWillChange.send()
    }

    func removeData(index: Int) {
        dataList.removeData(index: index)
        objectWillChange.send()
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
        ensureColorCount(dataList.count())
        objectWillChange.send()
    }

    private func maxDataAlert() {
        alertType = .maxData
        isShowAlert = true
    }

    func alert() -> Alert {
        switch alertType {
        case .maxData:
            return Alert(title: Text(LocalizedStringKey("maxAlertText")),
                         message: Text(LocalizedStringKey("maxAlertMessage")),
                         dismissButton: .default(Text("OK"), action: { self.isShowAlert = false }))
        }
    }
}
