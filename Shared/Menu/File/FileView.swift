//
//  ContentView.swift
//  Shared
//
//  Created by 上別縄祐也 on 2022/02/19.
//

import SwiftUI
import GoogleMobileAds

struct FileView: View {
    @StateObject var setting: Setting
    @State var tabIndex:Int = 0
    let fileId: Int
    init(fileId: Int) {
        self.fileId = fileId
        _setting = StateObject(wrappedValue: Setting(fileId: fileId))
    }
    
    var body: some View {
        let bounds = UIScreen.main.bounds
        let height = Double(bounds.height)
        VStack{
            TabView(selection: $tabIndex) {
                BarChartView(fileId: fileId)
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
        .onAppear(perform: {
            setting.save()
        })
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        FileView(fileId: 0)
    }
}
