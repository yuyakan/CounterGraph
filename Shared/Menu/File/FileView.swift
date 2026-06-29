//
//  ContentView.swift
//  Shared
//
//  Created by 上別縄祐也 on 2022/02/19.
//

import SwiftUI
import GoogleMobileAds

struct FileView: View {
    @ObservedObject var interstitial = Interstitial()
    @Environment(\.dismiss) var dismiss //iOS15
    @EnvironmentObject var menu: MenuViewModel
    @StateObject var setting: Setting
    @State var chartType: ChartType = .bar
    let fileId: String
    init(fileId: String) {
        _setting = StateObject(wrappedValue: Setting(fileId: fileId))
        self.fileId = fileId
    }

    var body: some View {
        VStack(spacing: 0) {
            if chartType.isBar() {
                BarChartView(fileId: fileId, chartType: $chartType)
                    .environmentObject(setting)
            } else {
                PieChartView(fileId: fileId, chartType: $chartType, interstitial: interstitial)
                    .environmentObject(setting)
            }
        }
        .onDisappear(perform: {
            menu.refresh.toggle()
            interstitial.interstitialAdLoaded.toggle()
        })
        .onAppear(perform: {
            interstitial.loadInterstitial()
            setting.save()
        })
        .navigationTitle(String(localized: "Main"))
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        FileView(fileId: "0")
    }
}
