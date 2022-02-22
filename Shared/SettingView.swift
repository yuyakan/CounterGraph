//
//  SettingView.swift
//  CounterGraph
//
//  Created by 上別縄祐也 on 2022/02/21.
//

import SwiftUI

struct SettingView: View {
    @Binding var title: String
    @Binding var textcolor: Color
    @Binding var titlecolor: Color
    @Binding var graphcolor: Color
    @Binding var backcolor: Color
    @Binding var buttoncolor: Color
    
    var body: some View {
        let bounds = UIScreen.main.bounds
        let height = Double(bounds.height)
        let width = Double(bounds.width)
        VStack(spacing: 0){
            Spacer()
            Text("Setting").font(.largeTitle).foregroundColor(titlecolor)
            Spacer()
            HStack{
                Text("Title").font(.largeTitle).foregroundColor(titlecolor).padding()
                Spacer()
                TextField("Bar Chart", text: $title)
                    .frame(width: width * 0.5,alignment: .center)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
            }.padding()
            HStack{
                Text("Color").font(.largeTitle).foregroundColor(titlecolor).frame(height: height*0.1).padding()
                Spacer()
            }.padding()
            HStack(spacing: 0){
                Circle()
                                .foregroundColor(titlecolor)
                                .frame(width:width * 0.35,height: height * 0.05)
                                .padding()
                ColorPicker("Title color", selection: $titlecolor).foregroundColor(textcolor).padding(.trailing, width*0.2)
            }.background(Color(red: 0.831, green: 0.831, blue: 0.831).opacity(0.5))
            HStack(spacing: 0){
                Circle()
                                .foregroundColor(textcolor)
                                .frame(width:width * 0.35,height: height * 0.05)
                                .padding()
                ColorPicker("Text color", selection: $textcolor).foregroundColor(textcolor).padding(.trailing, width*0.2)
            }.background(Color(hue: 0.0, saturation: 0.0, brightness: 0.918).opacity(0.5))
            HStack(spacing: 0){
                Circle()
                                .foregroundColor(graphcolor)
                                .frame(width:width * 0.35, height: height * 0.05)
                                .padding()
                ColorPicker("Graph color", selection: $graphcolor).foregroundColor(textcolor).padding(.trailing, width*0.2)
            }.background(Color(red: 0.831, green: 0.831, blue: 0.831).opacity(0.5))
            HStack(spacing: 0){
                Circle()
                                .foregroundColor(backcolor)
                                .frame(width:width * 0.35,height: height * 0.05)
                                .padding()
                ColorPicker("Background color", selection: $backcolor).foregroundColor(textcolor).padding(.trailing, width*0.2)
            }.background(Color(hue: 0.0, saturation: 0.0, brightness: 0.918).opacity(0.5))
            HStack(spacing: 0){
                Circle()
                                .foregroundColor(buttoncolor)
                                .frame(width:width * 0.35,height: height * 0.05)
                                .padding()
                ColorPicker("Button color", selection: $buttoncolor).foregroundColor(textcolor).padding(.trailing, width*0.2)
            }.background(Color(red: 0.831, green: 0.831, blue: 0.831).opacity(0.5))
            .padding(.bottom, height*0.03)
        }.background(backcolor)
    }
}

