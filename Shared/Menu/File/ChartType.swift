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
