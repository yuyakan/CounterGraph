//
//  extensionColor.swift
//  CounterGraph
//
//  Created by 上別縄祐也 on 2023/11/11.
//

import Foundation
import SwiftUI

extension Color {
    /// アプリ共通のブランドカラー（ティール/シアン系）。
    /// ボタン・タイトル・アクセントに使う唯一のアクセント色。
    /// ライトはやや濃いめ、ダークは黒地で映えるよう明るめにする。
    static let brand = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.0, green: 0.70, blue: 0.73, alpha: 1.0)   // ダーク: 鮮やかな濃いティール
            : UIColor(red: 0.0, green: 0.48, blue: 0.52, alpha: 1.0)   // ライト: しっかり濃いティール
    })

    /// ライト/ダークそれぞれのブランドカラー（描画コンテキストで trait が解決されない場合に明示利用）。
    static let brandLight = Color(red: 0.0, green: 0.48, blue: 0.52)
    static let brandDark  = Color(red: 0.0, green: 0.70, blue: 0.73)
}

extension Color: Codable {
    enum CodingKeys: String, CodingKey {
        case red
        case green
        case blue
        case opacity
    }
    
    public func encode(to encoder: Encoder) throws {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var opacity: CGFloat = 0
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: &opacity)
        try container.encode(red, forKey: .red)
        try container.encode(green, forKey: .green)
        try container.encode(blue, forKey: .blue)
        try container.encode(opacity, forKey: .opacity)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let red = try container.decode(Double.self, forKey: .red)
        let green = try container.decode(Double.self, forKey: .green)
        let blue = try container.decode(Double.self, forKey: .blue)
        let opacity = try container.decode(Double.self, forKey: .opacity)
        self.init(red: red, green: green, blue: blue, opacity: opacity)
    }
}
