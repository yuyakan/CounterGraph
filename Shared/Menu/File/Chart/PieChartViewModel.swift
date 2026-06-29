//
//  PieChartViewModel.swift
//  CounterGraph
//
//  Created by 上別縄祐也 on 2023/11/10.
//

import Foundation
import SwiftUI

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
    
    func angles() -> [Double] {
        let ratio360List = dataList.getRatio().map {$0 * 360.0}
        var angles: [Double] = [0.0]
        for index in 0..<ratio360List.count {
            angles.append(angles[index] + ratio360List[index])
        }
        return angles
    }
    
    func names() -> [String] {
        return dataList.names()
    }
    
    func labelPositions(radius: Double, centerX: Double, centerY: Double, angles: [Double]) -> [CGPoint] {
        var labelPositions: [CGPoint] = []
        coordinates(radius: radius, angles: angles).forEach { position in
            labelPositions.append(CGPoint(x: centerX + position.0, y: centerY + position.1 + 15))
        }
        return labelPositions
    }
    
    func percentPositions(radius: Double, centerX: Double, centerY: Double, angles: [Double]) -> [CGPoint] {
        var percentPositions: [CGPoint] = []
        coordinates(radius: radius/1.65, angles: angles).forEach { position in
            percentPositions.append(CGPoint(x: centerX + position.0, y: centerY + position.1 + 12))
        }
        return percentPositions
    }
    
    private func coordinates(radius: Double, angles: [Double]) -> Zip2Sequence<[Double], [Double]>{
        let ratioRasianList = centerAngles(angles: angles).map {3.14 * $0 / 180.0}
        let xList = ratioRasianList.map {cos($0) * radius}
        let yList = ratioRasianList.map {sin($0) * radius}
        return zip(xList, yList)
    }
    
    private func centerAngles(angles: [Double]) -> [Double] {
        var centerAngles: [Double] = []
        for index in 0..<angles.count-1 {
            centerAngles.append((angles[index] + angles[index+1])/2)
        }
        return centerAngles
    }
    
    func percents() ->[String] {
        return dataList.getRatio().map { String(format: "%.1f", $0 * 100) + "%" }
    }
}
