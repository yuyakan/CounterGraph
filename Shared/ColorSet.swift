//
//  ColorSet.swift
//  CounterGraph
//
//  Created by 上別縄祐也 on 2022/02/21.
//

import SwiftUI
import UIKit

class ColorSet: ObservableObject{
    @Published var graphcolor = Color.purple
    @Published var backcolor = Color.white
    @Published var buttoncolor = Color.purple
}
