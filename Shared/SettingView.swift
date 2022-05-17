//
//  SettingView.swift
//  CounterGraph
//
//  Created by 上別縄祐也 on 2022/02/21.
//

import SwiftUI

struct SettingView: View {
    @Binding var title: String
    @Binding var textColor: Color
    @Binding var titleColor: Color
    @Binding var graphColor: Color
    @Binding var backColor: Color
    @Binding var buttonColor: Color
    
    var body: some View {
        let bounds = UIScreen.main.bounds
        let height = Double(bounds.height)
        let width = Double(bounds.width)
        ZStack{
            backColor.edgesIgnoringSafeArea(.all)
            VStack(spacing: height * 0.03){
                Text("Setting").font(.largeTitle).foregroundColor(titleColor).padding(.top)
                HStack{
                    Text("Title").font(.largeTitle).foregroundColor(titleColor).padding(.leading)
                    Spacer()
                    TextField("Bar Chart", text: $title)
                        .frame(width: width * 0.5,alignment: .center)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                }.padding(.leading)
                VStack(spacing: 2){
                    HStack{
                        Text("Color").font(.largeTitle).foregroundColor(titleColor).padding(.leading)
                        Spacer()
                    }.padding([.leading, .bottom])
                    HStack(spacing: 0){
                        Circle()
                                        .foregroundColor(titleColor)
                                        .frame(width:width * 0.35,height: height * 0.035)
                                        .padding()
                        ColorPicker("Title color", selection: $titleColor).foregroundColor(textColor).padding(.trailing, width*0.2)
                    }.background(Color(red: 0.831, green: 0.831, blue: 0.831).opacity(0.5))
                    HStack(spacing: 0){
                        Circle()
                                        .foregroundColor(textColor)
                                        .frame(width:width * 0.35,height: height * 0.035)
                                        .padding()
                        ColorPicker("Text color", selection: $textColor).foregroundColor(textColor).padding(.trailing, width*0.2)
                    }.background(Color(hue: 0.0, saturation: 0.0, brightness: 0.918).opacity(0.5))
                    HStack(spacing: 0){
                        Circle()
                                        .foregroundColor(graphColor)
                                        .frame(width:width * 0.35, height: height * 0.035)
                                        .padding()
                        ColorPicker("Graph color", selection: $graphColor).foregroundColor(textColor).padding(.trailing, width*0.2)
                    }.background(Color(red: 0.831, green: 0.831, blue: 0.831).opacity(0.5))
                    HStack(spacing: 0){
                        Circle()
                                        .foregroundColor(backColor)
                                        .frame(width:width * 0.35,height: height * 0.035)
                                        .padding()
                        ColorPicker("Background color", selection: $backColor).foregroundColor(textColor).padding(.trailing, width*0.2)
                    }.background(Color(hue: 0.0, saturation: 0.0, brightness: 0.918).opacity(0.5))
                    HStack(spacing: 0){
                        Circle()
                                        .foregroundColor(buttonColor)
                                        .frame(width:width * 0.35,height: height * 0.035)
                                        .padding()
                        ColorPicker("Button color", selection: $buttonColor).foregroundColor(textColor).padding(.trailing, width*0.2)
                    }.background(Color(red: 0.831, green: 0.831, blue: 0.831).opacity(0.5))
                    .padding(.bottom, height*0.01)
                }
            }
        }
    }
}

