//
//  LineChart.swift
//  CounterGraph
//
//  Created by 上別縄祐也 on 2022/02/19.
//

import SwiftUI
import Charts
 
struct LineChart : UIViewRepresentable {
    
    typealias UIViewType = LineChartView
     
    func makeUIView(context: Context) -> LineChartView {
            let lineChartView = LineChartView()
            lineChartView.data = setData()
            
            lineChartView.backgroundColor = .darkGray //バックグラウンドカラーの変更
            lineChartView.data!.setValueFont(.systemFont(ofSize: 20, weight: .light)) //データのフォントサイズとウエイトの変更
            lineChartView.data!.setValueTextColor(.white)
            lineChartView.data!.setDrawValues(true) //データの値表示（falseに設定すると非表示）
            lineChartView.rightAxis.enabled = false //右側のX軸非表示
            lineChartView.leftAxis.enabled = true
        
//            lineChartView.animate(xAxisDuration: 2.5) //表示の際のアニメーション効果（この場合はX軸方法で2.5秒）
            
            //Y軸表示の設定
            let yAxis = lineChartView.leftAxis // lineChartView.leftAxisを変数で定義
            yAxis.labelFont = .boldSystemFont(ofSize: 12) //Y軸単位のフォントサイズ
            yAxis.setLabelCount(5, force: false) //Y軸の表示罫線数（falseにすると指定無し）
            yAxis.labelTextColor = .white //Y軸単位のテキストカラー
            yAxis.axisLineColor = .black //Y軸単位の軸のカラー
            yAxis.labelPosition = .outsideChart //Y軸単位のポジション(.insideChartにすると内側で表示)

            //X軸表示の設定
            let xAxis = lineChartView.xAxis // lineChartView.xAxisを変数で定義
            xAxis.labelPosition = .bottom //X軸単位のポジション(下部に表示)
            xAxis.labelFont = .boldSystemFont(ofSize: 12)
            xAxis.setLabelCount(5, force: true)
            xAxis.labelTextColor = .white
            xAxis.axisLineColor = .black
            
            return lineChartView
        }
        
        func updateUIView(_ uiView: LineChartView, context: Context) {
     
        }
        
        let yValue:[ChartDataEntry] = [
            ChartDataEntry(x: 1, y: 10.0),
            ChartDataEntry(x: 2, y: 20.0),
            ChartDataEntry(x: 3, y: 60.0),
            ChartDataEntry(x: 4, y: 40.0),
            ChartDataEntry(x: 5, y: 20.0)
        ]
        
    func setData() -> LineChartData{
            let set = LineChartDataSet(entries: yValue,label: "")
            let data = LineChartData(dataSet: set)
            
            set.mode = .cubicBezier //線表示を曲線で表示
            set.drawCirclesEnabled = false //各データを丸記号表示を非表示
            set.lineWidth = 3 //線の太さの指定
            set.setColor(NSUIColor.green) //線の色の指定
            set.fill = Fill(color: .green) //塗りつぶし色の指定
            set.fillAlpha = 0.2 //塗りつぶし色の不透明度指定
            set.drawFilledEnabled = true //値の塗りつぶし表示
            
            return data
        }
 
}
 
