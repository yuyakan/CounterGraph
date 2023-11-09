//
//  BarChart.swift
//  CounterGraph
//
//  Created by 上別縄祐也 on 2022/02/19.
//

import SwiftUI


struct BarChartView: View {
    @Binding var title: String
    @Binding var titleColor: Color
    @Binding var textColor: Color
    @Binding var graphColor: Color
    @Binding var backColor: Color
    @Binding var buttonColor: Color

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
        let fixedHeight = height * 0.5
        let fixedWidth = width * 0.8
        let max = barValues.max() ?? 1
        let bars = barValues.count
        
        
        ZStack{
            VStack{
                Spacer()
                Text(title).foregroundColor(titleColor)
                    .font(.largeTitle)
                    .padding()
                HStack(alignment: .center, spacing: (fixedWidth/Double(bars))/8)
                {
                    
                    ForEach(0..<bars, id: \.self){
                        index in
                        VStack(spacing: 0){
                            ZStack (alignment: .bottom) {
                                RoundedRectangle(cornerRadius: CGFloat(integerLiteral: 0))
                                    .frame(width: (fixedWidth/Double(bars))/2 , height: fixedHeight * 0.6).foregroundColor(.white.opacity(0))
                                VStack(spacing:0) {
                                    Text("\(Int(barValues[index]))")
                                        .frame(width: (fixedWidth/Double(bars)))
                                        .foregroundColor(textColor)
                                        .padding(.bottom, fixedHeight * 0.02)
                                    RoundedRectangle(cornerRadius: CGFloat(integerLiteral:  0)).fill(LinearGradient(gradient: Gradient(colors: [graphColor, graphColor.opacity(0.7), graphColor.opacity(0.4)]), startPoint: .top, endPoint: .bottom))
                                        .frame(width: (fixedWidth/Double(bars))/2, height: (barValues[index]/max)*fixedHeight*0.5)
                                    }
                                }
                            Text("\(barName[index])")
                                .frame(height: fixedHeight/8)
                                .frame(maxWidth: (fixedWidth/Double(bars)))
                                .foregroundColor(textColor)
                                .padding(.top, height * 0.015)
                                .padding(.bottom, height * 0.01)
                            
                            VStack(spacing: 0){
                                Button(action: {
                                    barValues[index] = barValues[index] + CGFloat(unit)
                                }) {
                                    if(flag){
                                        Text("＋")
                                            .font(.system(size: height * 0.043, design: .default))
                                            .multilineTextAlignment(.center)
                                    }
                                }
                                    .accentColor(Color.white)
                                    .background(buttonColor)
                                    .clipShape(Circle())
                                Button(action: {
                                    barValues[index] = barValues[index] - CGFloat(unit)
                                }) {
                                    if(flag){
                                        Text("ー")
                                            .font(.system(size: height * 0.043, design: .default))
                                            .multilineTextAlignment(.center)
                                    }
                                }
                                    .accentColor(Color.white)
                                    .background(buttonColor)
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
                                    .frame(width: fixedWidth * 0.2)
                        Text("/1unit")
                    }
                }.padding([.leading, .bottom, .trailing], height * 0.02)
                HStack(spacing: 0){
                    Spacer()
                    TextField("Jack", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: fixedWidth * 0.3)
                    Spacer()
                    TextField("", value: $balance, formatter: NumberFormatter())
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.default)
                                .frame(width: fixedWidth * 0.3)
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
                            .font(.system(size: height * 0.045, design: .default))
                            .frame(width: width * 0.2, alignment: .center)
                    })
                        .accentColor(Color.white)
                        .background(buttonColor)
                        .clipShape(Circle())
                    Button(action: {
                        if barValues.count != 0 {
                            barValues.removeLast()
                            barName.removeLast()
                        }
                    }, label: {
                        Text("ー")
                            .font(.system(size: height * 0.045, design: .default))
                            .frame(width: width * 0.2, alignment: .center)
                    })
                        .accentColor(Color.white)
                        .background(buttonColor)
                        .clipShape(Circle())
                    Spacer()
                }.opacity(flag ? 1:0).padding(.bottom, fixedHeight * 0.05)
                    .alert(isPresented: $alert) {
                                Alert(title: Text("The name is already used"),
                                      message: Text("Please give it a different name"),
                                      dismissButton: .default(Text("OK"),
                                                              action: {alert = false}))
                            }
            }
        }.background(backColor)
    }
}
