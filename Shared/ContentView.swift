//
//  ContentView.swift
//  Shared
//
//  Created by 上別縄祐也 on 2022/02/19.
//

import SwiftUI
import GoogleMobileAds

struct ContentView: View {
    
    @State var title: String = String(localized: "Result")
    @State var titleColor: Color = Color.purple
    @State var textColor: Color = Color.black
    @State var graphColor = Color.purple
    @State var backColor = Color.white
    @State var buttonColor = Color.purple
    @State var tabIndex:Int = 0
    var body: some View {
        let bounds = UIScreen.main.bounds
        let height = Double(bounds.height)
        VStack{
            TabView(selection: $tabIndex) {
                BarChartView(title: $title, titleColor: $titleColor, textColor: $textColor, graphColor: $graphColor, backColor: $backColor, buttonColor: $buttonColor).tabItem { Group{
                                Image(systemName: "chart.bar")
                                Text("Bar charts")
                            }
                }.tag(0)
                SettingView(title: $title, textColor: $textColor, titleColor: $titleColor, graphColor: $graphColor, backColor: $backColor, buttonColor: $buttonColor).tabItem { Group{
                                Image(systemName: "gearshape")
                                Text("Setting")
                            }}.tag(1)
            }.accentColor(buttonColor)
            AdView().frame(width: 320, height: 50)
                .padding(.top, height * 0.005)
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
