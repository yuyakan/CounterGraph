//
//  Setting.swift
//  CounterGraph
//
//  Created by 上別縄祐也 on 2023/11/10.
//

import Foundation
import SwiftUI

class Setting: ObservableObject{
    @Published var title: String = String(localized: "Result")
    @Published var titleColor: Color = Color.purple
    @Published var textColor: Color = UITraitCollection.current.userInterfaceStyle == .dark ? Color.white : Color.black
    @Published var graphColor = Color.purple
    @Published var backColor = UITraitCollection.current.userInterfaceStyle == .dark ? Color.black : Color.white
    @Published var buttonColor = Color.purple
    
    init() {
        if let title = UserDefaults.standard.string(forKey: "Title"){
            self.title = title
        }
        
//        if let titleColor = UserDefaults.standard.object(forKey: "titleColor") as? Color,
//           let textColor = UserDefaults.standard.object(forKey: "textColor") as? Color,
//           let graphColor = UserDefaults.standard.object(forKey: "graphColor") as? Color,
//           let backColor = UserDefaults.standard.object(forKey: "titleColor") as? Color,
//           let buttonColor = UserDefaults.standard.object(forKey: "textColor") as? Color {
//            self.titleColor = titleColor
//            self.textColor = textColor
//            self.graphColor = graphColor
//            self.backColor = backColor
//            self.buttonColor = buttonColor
//        }
    }
    
    func save() {
        saveTitle()
//        saveColor()
    }
    
    private func saveTitle() {
        UserDefaults.standard.setValue(title, forKey: "Title")
    }
    
//    private func saveColor() {
//        UserDefaults.standard.set(titleColor, forKey: "titleColor")
//        UserDefaults.standard.set(textColor, forKey: "textColor")
//        UserDefaults.standard.set(graphColor, forKey: "graphColor")
//        UserDefaults.standard.set(backColor, forKey: "backColor")
//        UserDefaults.standard.set(buttonColor, forKey: "buttonColor")
//    }
    
    
}
