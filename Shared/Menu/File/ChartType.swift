//
//  ChartType.swift
//  CounterGraph
//
//  Created by 上別縄祐也 on 2023/11/12.
//

import Foundation

enum ChartType {
    case bar
    case pie

    func isBar() -> Bool {
        return self == .bar
    }
}

/// 棒グラフの向き（縦棒 / 横棒）。
enum BarOrientation {
    case vertical
    case horizontal
}
