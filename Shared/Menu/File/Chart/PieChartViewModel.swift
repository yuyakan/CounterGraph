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
    private let dataList: DataList
    

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
    func entries() -> [SectorEntry] {
        let percents = self.percents()
        return (0..<dataList.count()).map { index in
            SectorEntry(id: index,
                        name: dataList.name(index: index),
                        value: dataList.value(index: index),
                        color: index < colors.count ? colors[index] : PieChartViewModel.defaultColors[index % PieChartViewModel.defaultColors.count],
                        percent: index < percents.count ? percents[index] : "")
        }
    }
}
