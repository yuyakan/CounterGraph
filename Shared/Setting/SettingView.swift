//
//  SettingView.swift
//  CounterGraph
//
//  Created by 上別縄祐也 on 2022/02/21.
//

import SwiftUI

struct SettingView: View {
    @EnvironmentObject var setting: Setting
    
    var body: some View {
        let bounds = UIScreen.main.bounds
        let height = Double(bounds.height)
        let width = Double(bounds.width)
        ZStack{
            setting.backColor.edgesIgnoringSafeArea(.all)
            VStack(spacing: height * 0.03){
                Spacer()
                    Text("Title")
                        .font(.largeTitle)
                        .foregroundColor(setting.titleColor)
                        .padding(.leading)
                    TextField("Result", text: $setting.title)
                        .frame(width: width * 0.5,alignment: .center)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Spacer()
                Text("Color").font(.largeTitle).foregroundColor(setting.titleColor).padding(.leading)
                VStack(spacing: 2){
                    HStack(spacing: 0){
                        ColorPicker(String(localized: "title"), selection: $setting.titleColor).foregroundColor(setting.textColor).padding(.horizontal, width*0.2)
                    }.frame(height: height*0.07)
                    Divider()
                        .frame(width: width * 0.8)
                    
                    HStack(spacing: 0){
                        ColorPicker(String(localized: "Text"), selection: $setting.textColor).foregroundColor(setting.textColor).padding(.horizontal, width*0.2)
                    }
                    .frame(height: height*0.07)
                    Divider()
                        .frame(width: width * 0.8)
                    
                    HStack(spacing: 0){
                        ColorPicker(String(localized: "Graph"), selection: $setting.graphColor).foregroundColor(setting.textColor).padding(.horizontal, width*0.2)
                    }
                    .frame(height: height*0.07)
                    Divider()
                        .frame(width: width * 0.8)
                    
                    HStack(spacing: 0){
                        ColorPicker(String(localized: "Background"), selection: $setting.backColor).foregroundColor(setting.textColor).padding(.horizontal, width*0.2)
                    }
                    .frame(height: height*0.07)
                    Divider()
                        .frame(width: width * 0.8)
                    
                    HStack(spacing: 0){
                        ColorPicker(String(localized: "Button"), selection: $setting.buttonColor).foregroundColor(setting.textColor).padding(.horizontal, width*0.2)
                    }
                    .frame(height: height*0.07)
                    Divider()
                        .frame(width: width * 0.8)
                        .padding(.bottom, height*0.01)
                }
                
                Spacer()
            }
        }.onDisappear(perform: {
            setting.save()
        })
    }
}

