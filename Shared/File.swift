//
//  File.swift
//  CounterGraph
//
//  Created by 上別縄祐也 on 2022/02/21.
//

import SwiftUICharts
import SwiftUI


class File: ObservableObject{
    func makeData() -> PieChartData {
        let data = PieDataSet(
            dataPoints: [
                PieChartDataPoint(value: 5, description: "One",   colour: .blue  , label: .label(text: "Tom", colour: .white, font: .title)),
                PieChartDataPoint(value: 2, description: "Two",   colour: .red   , label: .label(text: "Ann", colour: .white, font: .title)),
                PieChartDataPoint(value: 9, description: "Three", colour: .purple, label: .label(text: "Casey", colour: .white, font: .title)),
                PieChartDataPoint(value: 6, description: "Four",  colour: .green , label: .label(text: "Brian", colour: .white, font: .title)),
                PieChartDataPoint(value: 4, description: "Five",  colour: .orange, label: .label(text: "Bob", colour: .white, font: .title)),
            ],
            legendTitle: "Data")
        
        return PieChartData(dataSets: data,
                            metadata: ChartMetadata(title: "Pie Chart"),
                            chartStyle: PieChartStyle(infoBoxPlacement: .header))
    }
}
