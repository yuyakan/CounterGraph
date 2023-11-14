//
//  PieChart.swift
//  CounterGraph
//
//  Created by 上別縄祐也 on 2023/11/10.
//

import SwiftUI

struct PieChartView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var setting: Setting
    @StateObject var pieChart: PieChartViewModel
    @Binding var chartType: ChartType
    @ObservedObject var interstitial: Interstitial
    let height = Double(UIScreen.main.bounds.height)
    let width = Double(UIScreen.main.bounds.width)
    let centerX: Double
    let centerY: Double
    
    init (fileId: String, chartType:  Binding<ChartType>, interstitial: Interstitial){
        _pieChart = StateObject(wrappedValue: PieChartViewModel(fileId: fileId))
        _chartType = chartType
        self.interstitial = interstitial
        self.centerX = width/2
        self.centerY = height/4
    }
    
    @State var isVisibleSetting = false
    var body: some View {
        let radius: CGFloat = CGFloat(width/2.9)
        let names = pieChart.names()
        let angles = pieChart.angles()
        let namePositions: [CGPoint] = pieChart.labelPositions(radius: width/2.5, centerX: centerX, centerY: centerY)
        let percents: [String] = pieChart.percents()
        let percentPositions: [CGPoint] = pieChart.percentPositions(radius: width/2.5, centerX: centerX, centerY: centerY)
        
        let blankList = [
            PersonalData(value: 80, name: String(localized: "Ann")),
            PersonalData(value: 230, name: String(localized: "Tom")),
            PersonalData(value: 500, name: String(localized: "Bob")),
            PersonalData(value: 320, name: String(localized: "Casey")),
            PersonalData(value: 120, name: String(localized: "Brian"))
        ]
        let blankAngles = [0.0, 23.04, 89.28, 233.28, 325.44, 360.0]
        let blankNamesPositions = [
            CGPoint(x: 350.53641346137726, y: 259.3787081945006),
            CGPoint(x: 284.10571720738767, y: 358.5261594952491),
            CGPoint(x: 47.68829439385735, y: 278.66474390136324),
            CGPoint(x: 221.68309135075444, y: 72.83024808288326),
            CGPoint(x: 346.462418199441, y: 180.85009938742232)
        ]
        let blankPercents = ["6.4%", "18.4%", "40.0%", "25.6%", "9.6%"]
        let blankPercentPositions = [
            CGPoint(x: 289.8554020978044, y: 244.01739890575791),
            CGPoint(x: 249.59437406508343, y: 304.106763330454),
            CGPoint(x: 106.3110875114287, y: 255.7059053947656),
            CGPoint(x: 211.76247960651784, y: 130.95772611083834),
            CGPoint(x: 287.3863140602673, y: 196.42430265904383)
        ]
        
        VStack {
            HStack(alignment: .top, spacing: 0) {
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
                        chartType = .bar
                    }, label: {
                        Image(systemName: "chart.pie.fill")
                            .accentColor(setting.buttonColor)
                            .font(.system(size: 30))
                            .padding(.top, 13)
                            .padding(.bottom, 7)
                            .padding(.trailing, 8)
                    })
                    Button(action: {
                        isVisibleSetting.toggle()
                    }, label: {
                        Image(systemName: isVisibleSetting ? "paintbrush.fill" : "paintbrush")
                            .accentColor(setting.buttonColor)
                            .font(.system(size: 24))
                            .padding(.trailing, 8)
                    })
                }
            }
            
            if(!isVisibleSetting){
                if height > 800 {
                    Text(setting.title).foregroundColor(setting.titleColor)
                        .font(.largeTitle)
                        .padding(.top, height*0.03)
                } else {
                    Text(setting.title).foregroundColor(setting.titleColor)
                        .font(.largeTitle)
                        .padding(.top, height*0.01)
                }
            }
            
            ZStack {
                if names.count == 0 {
                    ForEach(0..<(blankAngles.count - 1), id: \.self) { index in
                        Path { path in
                            path.move(to: CGPoint(x: centerX, y: centerY))
                            path.addArc(center: .init(x: centerX, y: centerY),
                                        radius: radius,
                                        startAngle: Angle(degrees: blankAngles[index]),
                                        endAngle: Angle(degrees: blankAngles[index+1]),
                                        clockwise: false)
                        }
                        .fill(Color.gray.opacity(0.2))
                        if !isVisibleSetting {
                            Canvas { context, size in
                                context.draw(Text(LocalizedStringKey(blankList[index].name))
                                    .font(.title2)
                                    .foregroundColor(Color.gray.opacity(0.2)),
                                             at: blankNamesPositions[index],
                                             anchor: .bottom)
                            }
                            
                            Canvas { context, size in
                                context.draw(Text(blankPercents[index])
                                    .font(.title2)
                                    .foregroundColor(.white),
                                             at: blankPercentPositions[index],
                                             anchor: .bottom)
                            }
                        }
                    }
                }
                
                ForEach(0..<(angles.count - 1), id: \.self) { index in
                    Path { path in
                        path.move(to: CGPoint(x: centerX, y: centerY))
                        path.addArc(center: .init(x: centerX, y: centerY),
                                    radius: radius,
                                    startAngle: Angle(degrees: angles[index]),
                                    endAngle: Angle(degrees: angles[index+1]),
                                    clockwise: false)
                    }
                    .fill(pieChart.colors[index])
                    
                    if !isVisibleSetting {
                        Canvas { context, size in
                            context.draw(Text(LocalizedStringKey(names[index]))
                                                .font(.title2)
                                                .foregroundColor(setting.textColor),
                                         at: namePositions[index],
                                         anchor: .bottom)
                        }
                        
                        Canvas { context, size in
                            context.draw(Text(percents[index])
                                .font(.title2)
                                            .foregroundColor(.white),
                                         at: percentPositions[index],
                                         anchor: .bottom)
                        }
                    }
                }
            }
            
            if(isVisibleSetting){
                if names.count == 0 {
                    Text(LocalizedStringKey("blank"))
                }
                HStack(alignment: .bottom, spacing: width * 0.1 / 5){
                    ForEach(0..<min(names.count, 5), id: \.self){ index in
                        VStack {
                            Text("\(names[index])")
                            ColorPicker("",selection:$pieChart.colors[index]).frame(height: 10)
                        }.frame(height: height * 0.063)
                            .frame(maxWidth: width * 0.8 / 5)
                            .foregroundColor(pieChart.colors[index])
                    }
                }.opacity(isVisibleSetting ? 1:0)
                HStack(alignment: .bottom, spacing: width * 0.1 / 5){
                    ForEach(5..<min(max(names.count,5), 10), id: \.self){ index in
                        VStack {
                            Text("\(names[index])")
                            ColorPicker("",selection:$pieChart.colors[index]).frame(height: 10)
                        }.frame(height: height * 0.063)
                            .frame(maxWidth: width * 0.8 / 5)
                            .foregroundColor(pieChart.colors[index])
                    }
                }.padding(.bottom, names.count>5 ? height*0.05 : height*0.1)
            }
            Spacer()
        }
        .onAppear(){
            interstitial.presentInterstitial()
        }
        .onDisappear(perform: {
            pieChart.save()
        })
        .background(setting.backColor)
    }
}

