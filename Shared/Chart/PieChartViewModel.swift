//
//  PieChartViewModel.swift
//  CounterGraph
//
//  Created by 上別縄祐也 on 2023/11/10.
//

import Foundation
import SwiftUI

class PieChartViewModel: ObservableObject {
    @Published var colors: [Color] = [Color.orange, Color.green, Color.blue, Color.red, Color.yellow, Color.pink, Color.purple, Color.mint, Color.indigo, Color.cyan]
    private let dataList: DataList
    
    init(dataList: DataList) {
        self.dataList = dataList
        
        let jsonDecoder = JSONDecoder()
        guard let pieColors = UserDefaults.standard.object(forKey: "pieColors") as? Data,
              let pieColors = try? jsonDecoder.decode([Color].self, from: pieColors)else { return }
        self.colors = pieColors
    }
    
    func save() {
        let jsonEncoder = JSONEncoder()
        guard let colors = try? jsonEncoder.encode(colors) else { return }
        UserDefaults.standard.set(colors, forKey: "pieColors")
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
    
    func labelPositions(radius: Double, centerX: Double, centerY: Double) -> [CGPoint] {
        var labelPositions: [CGPoint] = []
        coordinates(radius: radius).forEach { position in
            labelPositions.append(CGPoint(x: centerX + position.0, y: centerY + position.1 + 15))
        }
        return labelPositions
    }
    
    func percentPositions(radius: Double, centerX: Double, centerY: Double) -> [CGPoint] {
        var percentPositions: [CGPoint] = []
        coordinates(radius: radius/1.65).forEach { position in
            percentPositions.append(CGPoint(x: centerX + position.0, y: centerY + position.1 + 12))
        }
        return percentPositions
    }
    
    private func coordinates(radius: Double) -> Zip2Sequence<[Double], [Double]>{
        let ratioRasianList = centerAngles().map {3.14 * $0 / 180.0}
        let xList = ratioRasianList.map {cos($0) * radius}
        let yList = ratioRasianList.map {sin($0) * radius}
        return zip(xList, yList)
    }
    
    private func centerAngles() -> [Double] {
        let angles = angles()
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
