//
//  Setting.swift
//  CounterGraph
//
//  Created by 上別縄祐也 on 2023/11/10.
//

import Foundation
import SwiftUI

class Setting: ObservableObject{
    @Published var title: String = String(localized: "newData")
    @Published var titleColor: Color = Color.purple
    @Published var textColor: Color = UITraitCollection.current.userInterfaceStyle == .dark ? Color.white : Color.black
    @Published var graphColor = Color.purple
    @Published var backColor = UITraitCollection.current.userInterfaceStyle == .dark ? Color.black : Color.white
    @Published var buttonColor = Color.purple
    let fileId: Int
    
    init(fileId: Int) {
        self.fileId = fileId
        
        if let title = UserDefaults.standard.string(forKey: "Title_file\(fileId)"){
            self.title = title
        } else {
            if fileId == 0 {
                self.title = String(localized: "Result")
            }
        }
        
        let jsonDecoder = JSONDecoder()
        guard let titleColor = UserDefaults.standard.data(forKey: "titleColor_file\(fileId)"),
              let textColor = UserDefaults.standard.data(forKey: "textColor_file\(fileId)"),
              let graphColor = UserDefaults.standard.data(forKey: "graphColor_file\(fileId)"),
              let backColor = UserDefaults.standard.data(forKey: "backColor_file\(fileId)"),
              let buttonColor = UserDefaults.standard.data(forKey: "buttonColor_file\(fileId)") else { return }
        guard let titleColor = try? jsonDecoder.decode(Color.self, from: titleColor),
              let textColor = try? jsonDecoder.decode(Color.self, from: textColor),
              let graphColor = try? jsonDecoder.decode(Color.self, from: graphColor),
              let backColor = try? jsonDecoder.decode(Color.self, from: backColor),
              let buttonColor = try? jsonDecoder.decode(Color.self, from: buttonColor) else { return }
            
        self.titleColor = titleColor
        self.textColor = textColor
        self.graphColor = graphColor
        self.backColor = backColor
        self.buttonColor = buttonColor
    }
    
    func save() {
        saveTitle()
        saveColor()
    }
    
    private func saveTitle() {
        UserDefaults.standard.setValue(title, forKey: "Title_file\(fileId)")
    }
    
    private func saveColor() {
        let jsonEncoder = JSONEncoder()
        guard let titleColor = try? jsonEncoder.encode(titleColor),
              let textColor = try? jsonEncoder.encode(textColor),
              let graphColor = try? jsonEncoder.encode(graphColor),
              let backColor = try? jsonEncoder.encode(backColor),
              let buttonColor = try? jsonEncoder.encode(buttonColor) else { return }
        
        UserDefaults.standard.set(titleColor, forKey: "titleColor_file\(fileId)")
        UserDefaults.standard.set(textColor, forKey: "textColor_file\(fileId)")
        UserDefaults.standard.set(graphColor, forKey: "graphColor_file\(fileId)")
        UserDefaults.standard.set(backColor, forKey: "backColor_file\(fileId)")
        UserDefaults.standard.set(buttonColor, forKey: "buttonColor_file\(fileId)")
    }
}
