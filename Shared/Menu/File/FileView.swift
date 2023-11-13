//
//  ContentView.swift
//  Shared
//
//  Created by 上別縄祐也 on 2022/02/19.
//

import SwiftUI
import GoogleMobileAds

struct FileView: View {
    @EnvironmentObject var menu: MenuViewModel
    @StateObject var setting: Setting
    @State var chartType: ChartType = .bar
    @State var tabIndex:Int = 0
    let fileId: Int
    init(fileId: Int) {
        _setting = StateObject(wrappedValue: Setting(fileId: fileId))
        self.fileId = fileId
    }
    
    var body: some View {
        let bounds = UIScreen.main.bounds
        let height = Double(bounds.height)
        VStack{
            TabView(selection: $tabIndex) {
                if chartType.isBar() {
                    BarChartView(fileId: fileId, chartType: $chartType)
                        .environmentObject(setting)
                        .tabItem { Group{
                            if #available(iOS 16.0, *) {
                                Image(systemName: "light.panel.fill")
                            } else {
                                Image(systemName: "display")
                            }
                            Text("Charts")
                        }
                    }.tag(0)
                } else {
                    PieChartView(fileId: fileId, chartType: $chartType)
                        .environmentObject(setting)
                        .tabItem { Group{
                            if #available(iOS 16.0, *) {
                                Image(systemName: "light.panel.fill")
                            } else {
                                Image(systemName: "display")
                            }
                            Text("Charts")
                        }
                    }.tag(0)
                }
                SettingView()
                    .environmentObject(setting)
                    .tabItem { Group{
                                Image(systemName: "gearshape")
                                Text("Setting")
                            }}.tag(1)
            }.accentColor(setting.buttonColor)
            AdView().frame(width: 320, height: 50)
                .padding(.top, height * 0.005)
        }
        .onDisappear(perform: {
            menu.refresh.toggle()
        })
        .onAppear(perform: {
            setting.save()
        })
        .navigationBarHidden(true)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        FileView(fileId: 0)
    }
}
