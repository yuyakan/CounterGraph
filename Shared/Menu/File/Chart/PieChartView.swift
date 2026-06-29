//
//  PieChart.swift
//  CounterGraph
//
//  Created by 上別縄祐也 on 2023/11/10.
//

import SwiftUI
import Charts

struct PieChartView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var setting: Setting
    @StateObject var pieChart: PieChartViewModel
    @Binding var chartType: ChartType
    @ObservedObject var interstitial: Interstitial
    let height = Double(UIScreen.main.bounds.height)
    let width = Double(UIScreen.main.bounds.width)

    init (fileId: String, chartType:  Binding<ChartType>, interstitial: Interstitial){
        _pieChart = StateObject(wrappedValue: PieChartViewModel(fileId: fileId))
        _chartType = chartType
        self.interstitial = interstitial
    }

    /// データ未登録時に表示するサンプルの扇形。
    private let blankEntries: [SectorEntry] = [
        SectorEntry(id: 0, name: String(localized: "Ann"),   value: 80,  color: .gray.opacity(0.2), percent: "6.4%"),
        SectorEntry(id: 1, name: String(localized: "Tom"),   value: 230, color: .gray.opacity(0.3), percent: "18.4%"),
        SectorEntry(id: 2, name: String(localized: "Bob"),   value: 500, color: .gray.opacity(0.2), percent: "40.0%"),
        SectorEntry(id: 3, name: String(localized: "Casey"), value: 320, color: .gray.opacity(0.3), percent: "25.6%"),
        SectorEntry(id: 4, name: String(localized: "Brian"), value: 120, color: .gray.opacity(0.2), percent: "9.6%")
    ]

    @State var isVisibleSetting = false
    var body: some View {
        let names = pieChart.names()
        let entries = pieChart.entries()

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
                Text(setting.title).foregroundColor(setting.titleColor)
                    .font(.largeTitle)
                    .padding(.top, height*0.03)
            }
            
            let displayedEntries = names.count == 0 ? blankEntries : entries
            Chart(displayedEntries) { entry in
                SectorMark(
                    angle: .value("Value", entry.value),
                    angularInset: 1.0
                )
                .foregroundStyle(entry.color)
                .annotation(position: .overlay) {
                    if !isVisibleSetting {
                        VStack(spacing: 2) {
                            Text(LocalizedStringKey(entry.name))
                                .font(.caption)
                                .foregroundColor(setting.textColor)
                            Text(entry.percent)
                                .font(.caption2)
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .chartLegend(.hidden)
            .frame(width: width * 0.8, height: width * 0.8)
            .padding(.top, height * 0.02)
            
            if(isVisibleSetting){
                if names.count == 0 {
                    Text(LocalizedStringKey("blank"))
                }
                HStack(alignment: .bottom, spacing: width * 0.1 / 5){
                    ForEach(Array(0..<min(names.count, 5)), id: \.self){ index in
                        VStack {
                            Text(LocalizedStringKey(names[index]))
                            ColorPicker("",selection:$pieChart.colors[index]).frame(height: 10)
                        }.frame(height: height * 0.063)
                            .frame(maxWidth: width * 0.8 / 5)
                            .foregroundColor(pieChart.colors[index])
                    }
                }.opacity(isVisibleSetting ? 1:0)
                HStack(alignment: .bottom, spacing: width * 0.1 / 5){
                    ForEach(Array(5..<min(max(names.count, 5), 10)), id: \.self){ index in
                        VStack {
                            Text(LocalizedStringKey(names[index]))
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

