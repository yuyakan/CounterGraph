//
//  ContentView.swift
//  Shared
//
//  Created by 上別縄祐也 on 2022/02/19.
//

import SwiftUI
import GoogleMobileAds

struct FileView: View {
    @EnvironmentObject var interstitial: Interstitial
    @EnvironmentObject var adCounter: AdCounter
    @Environment(\.dismiss) var dismiss //iOS15
    @EnvironmentObject var menu: MenuViewModel
    @StateObject var setting: Setting
    @State var chartType: ChartType = .bar
    @State private var orientation: BarOrientation = .vertical
    let fileId: String
    init(fileId: String) {
        _setting = StateObject(wrappedValue: Setting(fileId: fileId))
        self.fileId = fileId
    }

    var body: some View {
        // 棒グラフ / 円グラフをボトムタブで対等な2モードに分ける。
        // 棒グラフタブ内では縦/横の向きをヘッダーで切り替える。
        TabView(selection: $chartType) {
            BarChartView(fileId: fileId, orientation: $orientation, goBack: { dismiss() })
                .environmentObject(setting)
                .environmentObject(interstitial)
                .environmentObject(adCounter)
                .tabItem {
                    Label(String(localized: "Bar chart"), systemImage: "chart.bar.fill")
                }
                .tag(ChartType.bar)

            PieChartView(fileId: fileId, goBack: { dismiss() })
                .environmentObject(setting)
                .tabItem {
                    Label(String(localized: "Pie chart"), systemImage: "chart.pie.fill")
                }
                .tag(ChartType.pie)

            RankingView(fileId: fileId, goBack: { dismiss() })
                .environmentObject(setting)
                .tabItem {
                    Label(String(localized: "Ranking"), systemImage: "list.number")
                }
                .tag(ChartType.ranking)

            GroupChartView(fileId: fileId, goBack: { dismiss() })
                .environmentObject(setting)
                .tabItem {
                    Label(String(localized: "groups"), systemImage: "square.grid.2x2.fill")
                }
                .tag(ChartType.group)
        }
        .tint(Color.brand)
        .onDisappear(perform: {
            menu.refresh.toggle()
        })
        .onAppear(perform: {
            setting.save()
            // メニューから詳細画面へ遷移した直後。条件を満たせば広告を表示する。
            interstitial.presentIfReady(counter: adCounter)
        })
        .navigationTitle(String(localized: "Main"))
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        FileView(fileId: "0")
            .environmentObject(MenuViewModel())
            .environmentObject(Interstitial())
            .environmentObject(AdCounter())
    }
}
