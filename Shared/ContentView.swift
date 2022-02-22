//
//  ContentView.swift
//  Shared
//
//  Created by 上別縄祐也 on 2022/02/19.
//

import SwiftUI

struct ContentView: View {
    
    @State var title: String = "Bar Chart"
    @State var titlecolor: Color = Color.purple
    @State var textcolor: Color = Color.black
    @State var graphcolor = Color.purple
    @State var backcolor = Color.white
    @State var buttoncolor = Color.purple
    @State var tabIndex:Int = 0
    var body: some View {
        TabView(selection: $tabIndex) {
            BarChartView(title: $title, titlecolor: $titlecolor, textcolor: $textcolor, graphcolor: $graphcolor, backcolor: $backcolor, buttoncolor: $buttoncolor).tabItem { Group{
                            Image(systemName: "chart.bar")
                            Text("Bar charts")
                        }
            }.tag(0)
            SettingView(title: $title, textcolor: $textcolor, titlecolor: $titlecolor, graphcolor: $graphcolor, backcolor: $backcolor, buttoncolor: $buttoncolor).tabItem { Group{
                            Image(systemName: "gearshape")
                            Text("Setting")
                        }}.tag(1)
        }.accentColor(buttoncolor)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
