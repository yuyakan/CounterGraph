//
//  DiagonalLabel.swift
//  CounterGraph
//
//  棒の直下に斜め45度で表示する名前ラベル。棒グラフタブ・グループタブで共有する。
//

import SwiftUI
import UIKit

/// 棒の直下に斜め45度で表示する名前ラベル。
/// 起点(offsetで指定した棒の中心・下端)から右下へ文字を垂らす。
/// maxWidth を超える名前は2行まで折り返す。
struct DiagonalLabel: View {
    let text: String
    let color: Color
    let maxWidth: CGFloat
    let fontSize: CGFloat

    var body: some View {
        Text(text)
            .font(.system(size: fontSize))
            .foregroundColor(color)
            .lineLimit(2)
            .lineSpacing(-4)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: maxWidth, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
            // 起点(先頭文字の左上)を軸に時計回り45度。文字は右下へ伸び、隣の棒とは下方向にずれる。
            .rotationEffect(.degrees(45), anchor: .topLeading)
    }
}

/// 斜め45度ラベルに必要な縦方向の高さを見積もる共通関数。
/// 表示中の最長テキストを実測し、maxWidth で頭打ち（＝2行折り返し）した幅・高さから求める。
func estimatedDiagonalLabelHeight(names: [String], fontSize: CGFloat, maxWidth: CGFloat) -> CGFloat {
    let font = UIFont.systemFont(ofSize: fontSize)
    let attrs: [NSAttributedString.Key: Any] = [.font: font]
    let rawMaxWidth = names
        .map { ($0 as NSString).size(withAttributes: attrs).width }
        .max() ?? 0
    let effectiveWidth = min(rawMaxWidth, maxWidth)
    let lines: CGFloat = rawMaxWidth > maxWidth ? 2 : 1
    let textHeight = font.lineHeight * lines
    // 45度回転後の外接矩形の高さ = (幅 + 高さ) / √2 ＋ 余白
    return (effectiveWidth + textHeight) / 1.41421356 + 8
}
