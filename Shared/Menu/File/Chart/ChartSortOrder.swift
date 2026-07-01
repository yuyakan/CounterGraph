//
//  ChartSortOrder.swift
//  CounterGraph
//
//  グラフ・凡例の並び順。
//

import SwiftUI

enum ChartSortOrder: String, CaseIterable, Identifiable {
    case entry      // 登録順
    case descending // 値の大きい順
    case ascending  // 値の小さい順

    var id: String { rawValue }

    /// ソート切替メニューに表示するラベル。
    var label: LocalizedStringKey {
        switch self {
        case .entry:      return "sortEntry"
        case .descending: return "sortDescending"
        case .ascending:  return "sortAscending"
        }
    }

    /// メニュー項目のアイコン。
    var systemImage: String {
        switch self {
        case .entry:      return "list.number"
        case .descending: return "arrow.down"
        case .ascending:  return "arrow.up"
        }
    }
}
