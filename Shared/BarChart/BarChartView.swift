//
//  BarChart.swift
//  CounterGraph
//
//  Created by 上別縄祐也 on 2022/02/19.
//

import SwiftUI


struct BarChartView: View {
    @ObservedObject var barChart = BarChartViewModel()
    @EnvironmentObject var setting: Setting
    
    @State var unit: Int = 10
    @State var isVisibleSetting : Bool = false
    var body: some View {
        let bars = barChart.count()
        let bounds = UIScreen.main.bounds
        let height = Double(bounds.height)
        let width = Double(bounds.width)
        let fixedHeight = height * 0.5
        let fixedWidth = width * 0.8
        let baseframeWidth = fixedWidth / Double(bars)
        
        ZStack{
            VStack{
                HStack {
                    Button(action: {
                        isVisibleSetting.toggle()
                    }, label: {
                        Image(systemName: isVisibleSetting ? "square.and.pencil.circle.fill" : "square.and.pencil.circle")
                            .accentColor(setting.buttonColor)
                            .font(.system(size: 30))
                            .padding()
                    })
                    Spacer()
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
                
                Spacer()
                
                if(!isVisibleSetting){
                    Text(setting.title).foregroundColor(setting.titleColor)
                        .font(.largeTitle)
                        .padding()
                        .padding(.bottom)
                }

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
                                            .padding(.bottom)
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
                
                HStack(alignment: .center, spacing: baseframeWidth/8){
                    ForEach(0..<bars, id: \.self){ index in
                        VStack {
                            Text("\(barChart.name(index: index))")
                                .frame(height: fixedHeight/8)
                                .frame(maxWidth: baseframeWidth)
                                .foregroundColor(setting.textColor)
                                .padding(.top, height * 0.015)
                                .padding(.bottom, height * 0.01)
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
                    .opacity(isVisibleSetting ? 1:0).padding(.bottom, fixedHeight * 0.05)
                    .alert(isPresented: $barChart.alert) {
                                Alert(title: Text(LocalizedStringKey("AlertText")),
                                      message: Text(LocalizedStringKey("AlertMessage")),
                                      dismissButton: .default(Text("OK"),
                                                              action: {barChart.alert = false}))
                            }
                Spacer()
            }
        }.background(setting.backColor)
    }
}
