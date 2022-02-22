//
//  BarChart.swift
//  CounterGraph
//
//  Created by 上別縄祐也 on 2022/02/19.
//

import SwiftUI

struct BarChartView: View {
    @Binding var title: String
    @Binding var titlecolor: Color
    @Binding var textcolor: Color
    @Binding var graphcolor: Color
    @Binding var backcolor: Color
    @Binding var buttoncolor: Color

    @State var pickerSelection = 0
    @State var barValues : [CGFloat] = [80,230,500,320,120]
    @State var barName : [String] = ["Ann","Tom","Bob","Casey","Brian"]
    @State var name : String = "Jack"
    @State var balance: Double = 100
    @State var unit: Double = 10
    @State var alert : Bool = false
    @State var flag : Bool = false
    
    var body: some View {
        let bounds = UIScreen.main.bounds
        let height = Double(bounds.height)
        let width = Double(bounds.width)
        let height_mod = height * 0.5
        let width_mod = width * 0.8
        let max = barValues.max()!
        let nums = barValues.count
        
        
        ZStack{
            VStack{
                Spacer()
                Text(title).foregroundColor(titlecolor)
                    .font(.largeTitle)

                HStack(alignment: .center, spacing: (width_mod/Double(nums))/8)
                {
                    ForEach(0..<nums, id: \.self){
                        index in
                        VStack{
                            ZStack (alignment: .bottom) {
                                RoundedRectangle(cornerRadius: CGFloat(integerLiteral: 0))
                                    .frame(width: (width_mod/Double(nums))/2 , height: height_mod * 0.65).foregroundColor(.white.opacity(0))
                                VStack {
                                    Text("\(Int(barValues[index]))")
                                        .frame(width: (width_mod/Double(nums)))
                                        .foregroundColor(textcolor)
                                    RoundedRectangle(cornerRadius: CGFloat(integerLiteral:  0)).fill(LinearGradient(gradient: Gradient(colors: [graphcolor, graphcolor.opacity(0.7), graphcolor.opacity(0.4)]), startPoint: .top, endPoint: .bottom))
                                        .frame(width: (width_mod/Double(nums))/2, height: (barValues[index]/max)*height_mod*0.5)
                                    }
                                }
                            Text("\(barName[index])")
                                .frame(height: height_mod/7)
                                .frame(maxWidth: (width_mod/Double(nums)))
                                .foregroundColor(textcolor)
                            Text("")
                                .frame(maxWidth: (width_mod/Double(nums)))
                            
                            VStack{
                                Button(action: {
                                    barValues[index] = barValues[index] + CGFloat(unit)
                                }) {
                                    if(flag){
                                        Text("＋")
                                            .font(.largeTitle)
                                            .multilineTextAlignment(.center)
                                    }
                                }
                                    .accentColor(Color.white)
                                    .background(buttoncolor)
                                    .clipShape(Circle())
                                Button(action: {
                                    barValues[index] = barValues[index] - CGFloat(unit)
                                }) {
                                    if(flag){
                                        Text("ー")
                                            .font(.largeTitle)
                                            .multilineTextAlignment(.center)
                                    }
                                }
                                    .accentColor(Color.white)
                                    .background(buttoncolor)
                                    .clipShape(Circle())
                            }
                        }
                    }
                }
                
                HStack{
                    Toggle("",isOn: $flag).labelsHidden().padding(.leading, 10.0)
                    Spacer()
                    if flag {
                        TextField("", value: $unit, formatter: NumberFormatter())
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.default)
                                    .frame(width: width_mod * 0.2)
                        Text("/1unit")
                    }
                }.padding()
                HStack(spacing: 0){
                    Spacer()
                    TextField("Jack", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: width_mod * 0.3)
                    Spacer()
                    TextField("", value: $balance, formatter: NumberFormatter())
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.default)
                                .frame(width: width_mod * 0.3)
                    Spacer()
                    Button(action: {
                        if(barName.allSatisfy({ $0 != name })){
                            barValues.append(CGFloat(balance))
                            barName.append("\(name)")
                        }else{
                            alert = true
                        }
                    }, label: {
                        Text("＋")
                            .frame(width: width * 0.2, alignment: .center)
                            .font(.largeTitle)
                    })
                        .accentColor(Color.white)
                        .background(buttoncolor)
                        .clipShape(Circle())
                    Button(action: {
                        barValues.removeLast()
                        barName.removeLast()
                    }, label: {
                        Text("ー")
                            .frame(width: width * 0.2, alignment: .center)
                            .font(.largeTitle)
                    })
                        .accentColor(Color.white)
                        .background(buttoncolor)
                        .clipShape(Circle())
                    Spacer()
                }.padding(.bottom, height_mod * 0.1).opacity(flag ? 1:0)
                    .alert(isPresented: $alert) {
                                Alert(title: Text("The name is already used"),
                                      message: Text("Please give it a different name"),
                                      dismissButton: .default(Text("OK"),
                                                              action: {alert = false}))
                            }
            }
        }.background(backcolor)
    }
}
