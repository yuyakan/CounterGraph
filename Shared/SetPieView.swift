//
//  SetPieView.swift
//  CounterGraph
//
//  Created by 上別縄祐也 on 2022/02/21.
//

import SwiftUI
import SwiftUICharts

struct SetPieView: View {
    @ObservedObject var file = File()
    @State var name = "Tom"
    @State var balance: Double = 10
    var body: some View {
        let data: PieChartData = file.makeData()
        let bounds = UIScreen.main.bounds
        let width = Double(bounds.width)
        HStack{
            Spacer()
            TextField("Ken", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: width * 0.3)
            Spacer()
            TextField("", value: $balance, formatter: NumberFormatter())
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.default)
                        .frame(width: width * 0.3)
            Spacer()
            Button(action: {
                data.dataSets.dataPoints.append(PieChartDataPoint(value: balance, description: "One",   colour: .blue  , label: .label(text: name, colour: .white, font: .title)))
            }, label: {
                Text("＋")
                    .frame(width: width * 0.15, alignment: .center)
                    .font(.title)
            })
                .accentColor(Color.white)
                .background(Color.cyan)
                .clipShape(Circle())
            Button(action: {
                data.dataSets.dataPoints.removeLast()
            }, label: {
                Text("ー")
                    .frame(width: width * 0.15, alignment: .center)
                    .font(.title)
            })
                .accentColor(Color.white)
                .background(Color.cyan)
                .clipShape(Circle())
            Spacer()
        }
        Spacer()
    }
}

struct SetPieView_Previews: PreviewProvider {
    static var previews: some View {
        SetPieView()
    }
}
