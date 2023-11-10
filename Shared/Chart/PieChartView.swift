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
    let pieChart: PieChartViewModel
    let angles: [Double]
    let names: [String]
    let namePositions: [CGPoint]
    let percents: [String]
    let percentPositions: [CGPoint]
    let height = Double(UIScreen.main.bounds.height)
    let width = Double(UIScreen.main.bounds.width)
    let centerX: Double
    let centerY: Double
    
    init (dataList: DataList){
        pieChart = PieChartViewModel(dataList: dataList)
        self.centerX = width/2
        self.centerY = height/4
        self.angles = pieChart.angles()
        self.names = pieChart.names()
        self.namePositions = pieChart.labelPositions(radius: width/2.5, centerX: centerX, centerY: centerY)
        self.percents = pieChart.percents()
        self.percentPositions = pieChart.percentPositions(radius: width/2.5, centerX: centerX, centerY: centerY)
    }
    
    @State var isVisibleSetting = false
    @State var colors: [Color] = [Color.orange, Color.green, Color.blue, Color.red, Color.yellow, Color.pink, Color.purple, Color.mint, Color.indigo, Color.cyan]
    
    var body: some View {
        let radius: CGFloat = CGFloat(width/2.9)
        
        VStack {
            HStack {
                Button(action: {
                    dismiss()
                }, label: {
                    Image(systemName: "chart.bar.xaxis")
                        .accentColor(setting.buttonColor)
                        .font(.system(size: 30))
                        .padding()
                })
                Spacer()
                Button(action: {
                    isVisibleSetting.toggle()
                }, label: {
                    Image(systemName: isVisibleSetting ? "square.and.pencil.circle.fill" : "square.and.pencil.circle")
                        .accentColor(setting.buttonColor)
                        .font(.system(size: 30))
                        .padding()
                })
            }
            
            if(!isVisibleSetting){
                Text(setting.title).foregroundColor(setting.titleColor)
                    .font(.largeTitle)
                    .padding(.top, height*0.05)
            }
            
            ZStack {
                ForEach(0..<(angles.count - 1), id: \.self) { index in
                    Path { path in
                        path.move(to: CGPoint(x: centerX, y: centerY))
                        path.addArc(center: .init(x: centerX, y: centerY),
                                    radius: radius,
                                    startAngle: Angle(degrees: angles[index]),
                                    endAngle: Angle(degrees: angles[index+1]),
                                    clockwise: false)
                    }
                    .fill(colors[index])
                    
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
                HStack(alignment: .bottom, spacing: width * 0.1 / 5){
                    ForEach(0..<min(names.count, 5), id: \.self){ index in
                        VStack {
                            Text("\(names[index])")
                            ColorPicker("",selection:$colors[index]).frame(height: 10)
                        }.frame(height: height * 0.063)
                            .frame(maxWidth: width * 0.8 / 5)
                            .foregroundColor(colors[index])
                    }
                }.opacity(isVisibleSetting ? 1:0)
                HStack(alignment: .bottom, spacing: width * 0.1 / 5){
                    ForEach(5..<min(names.count, 10), id: \.self){ index in
                        VStack {
                            Text("\(names[index])")
                            ColorPicker("",selection:$colors[index]).frame(height: 10)
                        }.frame(height: height * 0.063)
                            .frame(maxWidth: width * 0.8 / 5)
                            .foregroundColor(colors[index])
                    }
                }.padding(.bottom, names.count>5 ? height*0.05 : height*0.1)
            }
            Spacer()
        }
        .navigationBarBackButtonHidden(true)
        .background(setting.backColor)
    }
}

struct PieChartView_Previews: PreviewProvider {
    static var previews: some View {
        PieChartView(dataList: DataList())
    }
}