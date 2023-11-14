//
//  BarChart.swift
//  CounterGraph
//
//  Created by 上別縄祐也 on 2022/02/19.
//

import SwiftUI


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
            }
            
            if(!isVisibleSetting){
                if height > 800 {
                    Text(setting.title).foregroundColor(setting.titleColor)
                        .font(.largeTitle)
                        .padding(.top, height*0.03)
                        .padding(.bottom, height*0.075)
                } else {
                    Text(setting.title).foregroundColor(setting.titleColor)
                        .font(.largeTitle)
                        .padding(.top, height*0.01)
                        .padding(.bottom, height*0.075)
                }
            }
            
            if bars == 0 {
                HStack(alignment: .bottom, spacing: fixedWidth/40){
                    ForEach(0..<5, id: \.self){ index in
                        ZStack (alignment: .bottom) {
                            VStack(spacing:0) {
                                Text("\(Int(blankList[index].value))")
                                    .frame(width: fixedWidth/5)
                                    .foregroundColor(Color.gray.opacity(0.4))
                                    .padding(.bottom, fixedHeight * 0.02)
                                RoundedRectangle(cornerRadius: CGFloat(integerLiteral:  0))
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: fixedWidth/10, height: (Double(blankList[index].value) / 500)*fixedHeight*0.5)
                            }
                        }
                    }
                }
            } else {
                HStack(alignment: .bottom, spacing: baseframeWidth/8){
                    ForEach(0..<bars, id: \.self){ index in
                        ZStack (alignment: .bottom) {
                            VStack(spacing:0) {
                                Button(action: {
                                    barChart.removeData(index: index)
                                }) {
                                    if(isVisibleSetting){
                                        Image(systemName: "trash")
                                            .accentColor(Color.red)
                                            .padding(.bottom, 6)
                                    }
                                }
                                Text("\(Int(barChart.value(index: index)))")
                                    .frame(width: baseframeWidth)
                                    .foregroundColor(setting.textColor)
                                    .padding(.bottom, fixedHeight * 0.02)
                                RoundedRectangle(cornerRadius: CGFloat(integerLiteral:  0))
                                    .fill(LinearGradient(gradient: Gradient(colors: [setting.graphColor, setting.graphColor.opacity(0.7), setting.graphColor.opacity(0.4)]), startPoint: .top, endPoint: .bottom))
                                    .frame(width: baseframeWidth/2, height: barChart.value(index: index) <= CGFloat(0) ? 0 :  (barChart.value(index: index)/barChart.maxValue())*fixedHeight*0.5)
                            }
                        }
                    }
                }
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
                    ForEach(0..<bars, id: \.self){ index in
                        VStack {
                            Text("\(barChart.name(index: index))")
                                .frame(height: fixedHeight/8)
                                .frame(maxWidth: baseframeWidth)
                                .foregroundColor(setting.textColor)
                                .padding(.top, height * 0.005)
                                .padding(.bottom, height * 0.005)
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
                                            .padding(.vertical, 10)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            Divider()
                .opacity(isVisibleSetting ? 1:0).frame(width: width*0.85)
            
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
            }.padding(.top, 10)
                .opacity(isVisibleSetting ? 1:0)
                .alert(isPresented: $barChart.isShowAlert) { barChart.alert() }
            Spacer()
        }
        .background(setting.backColor)
    }
}
