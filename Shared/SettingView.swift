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
                    Text("Title")
                        .font(.largeTitle)
                        .foregroundColor(titleColor)
                        .padding(.leading)
                    Spacer()
                    TextField("Result", text: $title)
                        .frame(width: width * 0.5,alignment: .center)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                }.padding(.leading)
                
                VStack(spacing: 2){
                    HStack{
                        Text("Color").font(.largeTitle).foregroundColor(titleColor).padding(.leading)
                        Spacer()
                    }.padding(.leading)
                    
                    HStack(spacing: 0){
                        ColorPicker(String(localized: "title"), selection: $titleColor).foregroundColor(textColor).padding(.horizontal, width*0.2)
                    }.frame(height: height*0.07)
                    Divider()
                        .frame(width: width * 0.8)
                    
                    HStack(spacing: 0){
                        ColorPicker(String(localized: "Text"), selection: $textColor).foregroundColor(textColor).padding(.horizontal, width*0.2)
                    }
                    .frame(height: height*0.07)
                    Divider()
                        .frame(width: width * 0.8)
                    
                    HStack(spacing: 0){
                        ColorPicker(String(localized: "Graph"), selection: $graphColor).foregroundColor(textColor).padding(.horizontal, width*0.2)
                    }
                    .frame(height: height*0.07)
                    Divider()
                        .frame(width: width * 0.8)
                    
                    HStack(spacing: 0){
                        ColorPicker(String(localized: "Background"), selection: $backColor).foregroundColor(textColor).padding(.horizontal, width*0.2)
                    }
                    .frame(height: height*0.07)
                    Divider()
                        .frame(width: width * 0.8)
                    
                    HStack(spacing: 0){
                        ColorPicker(String(localized: "Button"), selection: $buttonColor).foregroundColor(textColor).padding(.horizontal, width*0.2)
                    }
                    .frame(height: height*0.07)
                    Divider()
                        .frame(width: width * 0.8)
                        .padding(.bottom, height*0.01)
                }
            }
        }
    }
}

