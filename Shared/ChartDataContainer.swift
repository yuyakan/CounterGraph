//
//  ChartDataContainer.swift
//  CounterGraph
//
//  Created by 上別縄祐也 on 2022/02/21.
//
import SwiftUI
import UIKit

class ChartDataContainer :ObservableObject {
    @Published var percents: [Double] = [8, 15, 32, 45]
    @Published var chartData =
        [ChartData(color: Color(#colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 1)), percent: 8, value: 0),
         ChartData(color: Color(#colorLiteral(red: 1, green: 0.8323456645, blue: 0.4732058644, alpha: 1)), percent: 15, value: 0),
         ChartData(color: Color(#colorLiteral(red: 0.4508578777, green: 0.9882974029, blue: 0.8376303315, alpha: 1)), percent: 32, value: 0),
         ChartData(color: Color(#colorLiteral(red: 0.476841867, green: 0.5048075914, blue: 1, alpha: 1)), percent: 20, value: 0)]
        init() {
            calc()
        }
    func calc(){
        var value : CGFloat = 0
        
        for i in 0..<chartData.count {
            value += chartData[i].percent
            chartData[i].value = value
        }
    }
}

struct ChartData {
    var color : Color
    var percent : CGFloat
    var value : CGFloat
    
}
