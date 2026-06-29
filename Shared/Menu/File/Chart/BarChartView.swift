//
//  BarChart.swift
//  CounterGraph
//
//  Created by 上別縄祐也 on 2022/02/19.
//

import SwiftUI
import Charts


struct BarChartView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var setting: Setting
    @StateObject var barChart: BarChartViewModel
    @Binding var chartType: ChartType
    @State var unit: Int = 10
    @State var isVisibleSetting : Bool = false
    
    init(fileId: String, chartType:  Binding<ChartType>) {
        _barChart = StateObject(wrappedValue: BarChartViewModel(fileId: fileId))
        _chartType = chartType
    }
    
    var body: some View {
        let bars = barChart.count()
        let bounds = UIScreen.main.bounds
        let height = Double(bounds.height)
        let width = Double(bounds.width)
        let fixedHeight = height * 0.5
        let fixedWidth = width * 0.8
        let baseframeWidth = fixedWidth / Double(bars)
        let blankList = [
            PersonalData(value: 80, name: String(localized: "Ann")),
            PersonalData(value: 230, name: String(localized: "Tom")),
            PersonalData(value: 500, name: String(localized: "Bob")),
            PersonalData(value: 320, name: String(localized: "Casey")),
            PersonalData(value: 120, name: String(localized: "Brian"))
        ]
        
        VStack{
            HStack(alignment: .top , spacing: 0) {
                Button(action: {
                    dismiss()
                }, label: {
                    Image(systemName: "list.bullet")
                        .accentColor(setting.buttonColor)
                        .font(.system(size: 30))
                        .padding()
                })
                Spacer()
                VStack(spacing: 0) {
                    Button(action: {
                        chartType = .pie
                    }, label: {
                        Image(systemName: "chart.pie")
                            .accentColor(setting.buttonColor)
                            .font(.system(size: 30))
                            .padding(.top, 13)
                            .padding(.bottom, 7)
                            .padding(.trailing, 8)
                    })
                    if #available(iOS 16.0, *) {
                        Button(action: {
                            isVisibleSetting.toggle()
                        }, label: {
                            Image(systemName: isVisibleSetting ? "square.and.pencil.circle.fill" : "square.and.pencil.circle")
                                .accentColor(setting.buttonColor)
                                .font(.system(size: 30))
                                .padding(.trailing, 8)
                        })
                    } else {
                        Button(action: {
                            isVisibleSetting.toggle()
                        }, label: {
                            Image(systemName: isVisibleSetting ? "pencil.circle.fill" : "pencil.circle")
                                .accentColor(setting.buttonColor)
                                .font(.system(size: 30))
                                .padding(.trailing, 8)
                        })
                    }
                }
            }
            
            if isVisibleSetting {
                HStack{
                    Text(LocalizedStringKey("1unit:"))
                    TextField("", value: $unit, formatter: NumberFormatter())
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.default)
                        .frame(width: fixedWidth * 0.2)
                    Spacer()
                }.padding(.horizontal)
                Spacer()
            }
            
            if(!isVisibleSetting){
                Text(setting.title).foregroundColor(setting.titleColor)
                    .font(.largeTitle)
                    .padding(.top, height*0.03)
                    .padding(.bottom, height*0.075)
                
                if height > 1000 {
                    Spacer()
                }
            }
            
            if bars == 0 {
                // データ未登録時のサンプル表示（淡色のプレースホルダ）
                Chart(blankList, id: \.name) { item in
                    BarMark(
                        x: .value("Name", item.name),
                        y: .value("Value", item.value)
                    )
                    .foregroundStyle(Color.gray.opacity(0.3))
                    .annotation(position: .top) {
                        Text("\(item.value)")
                            .font(.caption)
                            .foregroundColor(Color.gray.opacity(0.4))
                    }
                }
                .chartYAxis(.hidden)
                .frame(height: fixedHeight * 0.5)
                .padding(.horizontal)
            } else {
                Chart(barChart.entries()) { entry in
                    // X軸は名前ではなく一意なindexにする。
                    // 名前にすると同名項目（既定名"Jack"など）が1本の棒に積み上がってしまう。
                    BarMark(
                        x: .value("Index", String(entry.id)),
                        y: .value("Value", max(entry.value, 0))
                    )
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [setting.graphColor, setting.graphColor.opacity(0.7), setting.graphColor.opacity(0.4)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .annotation(position: .top) {
                        Text("\(entry.value)")
                            .font(.caption)
                            .foregroundColor(setting.textColor)
                    }
                }
                .chartYAxis(.hidden)
                .chartXAxis(.hidden)
                .frame(height: fixedHeight * 0.5)
                .padding(.horizontal)
            }
            
            if bars == 0 {
                HStack(alignment: .center, spacing: fixedWidth/40){
                    ForEach(0..<5, id: \.self){ index in
                        VStack {
                            Text("\(blankList[index].name)")
                                .frame(height: fixedHeight/8)
                                .frame(maxWidth: fixedWidth/5)
                                .foregroundColor(Color.gray.opacity(0.4))
                                .padding(.top, height * 0.015)
                                .padding(.bottom, height * 0.01)
                        }
                    }
                }
                
                if(isVisibleSetting){
                    ZStack {
                        VStack(spacing: 0){
                            Image(systemName: "minus.circle")
                                .font(.system(size: 30))
                                .padding(.vertical, 10)
                            Image(systemName: "minus.circle")
                                .font(.system(size: 30))
                                .padding(.vertical, 10)
                        }.opacity(0)
                        Text(LocalizedStringKey("blankBar"))
                            .padding(.bottom)
                    }
                }
            } else {
                HStack(alignment: .center, spacing: baseframeWidth/8){
                    ForEach(Array(0..<bars), id: \.self){ index in
                        VStack {
                            Text(LocalizedStringKey(barChart.name(index: index)))
                                .frame(height: fixedHeight/8)
                                .frame(maxWidth: baseframeWidth)
                                .foregroundColor(setting.textColor)
                                .padding(.top, height > 800 ? height * 0.005 : 0)
                                .padding(.bottom, height > 800 ? height * 0.005 : 0)
                            VStack(spacing: 0){
                                Button(action: {
                                    barChart.plus(index: index, value: unit)
                                }) {
                                    if(isVisibleSetting){
                                        Image(systemName: "plus.circle")
                                            .accentColor(setting.buttonColor)
                                            .font(.system(size: 30))
                                    }
                                }
                                
                                Button(action: {
                                    barChart.minus(index: index, value: unit)
                                }) {
                                    if(isVisibleSetting){
                                        Image(systemName: "minus.circle")
                                            .accentColor(setting.buttonColor)
                                            .font(.system(size: 30))
                                            .padding(.vertical, height > 800 ? 10 : 6)
                                    }
                                }

                                Button(action: {
                                    barChart.removeData(index: index)
                                }) {
                                    if(isVisibleSetting){
                                        Image(systemName: "trash")
                                            .accentColor(Color.red)
                                            .font(.system(size: 22))
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            Spacer()
            if height > 800 {
                Divider()
                    .opacity(isVisibleSetting ? 1:0).frame(width: width*0.85)
            }
            
            HStack(spacing: 0){
                Spacer()
                TextField("Jack", text: $barChart.name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: fixedWidth * 0.3)
                    .padding(.trailing)
                TextField("", value: $barChart.value, formatter: NumberFormatter())
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.default)
                            .frame(width: fixedWidth * 0.3)
                Spacer()
                Button(action: {
                    barChart.addData()
                }, label: {
                    Image(systemName: "plus.square.on.square")
                        .accentColor(setting.buttonColor)
                        .font(.system(size: 30))
                })
                Spacer()
            }.padding(.top, height > 800 ? 10 : 0)
                .opacity(isVisibleSetting ? 1:0)
                .alert(isPresented: $barChart.isShowAlert) { barChart.alert() }
            Spacer()
        }
        .background(setting.backColor)
    }
}
