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
}