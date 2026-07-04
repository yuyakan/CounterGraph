//
//  RankingView.swift
//  CounterGraph
//
//  項目を多い順に並べたランキング。棒グラフとの重複を避けるため、
//  メダル等の装飾は使わず 01/02/03 のミニマルな番号付きリストで見せる。
//  1位のみブランドカラーのアクセントで控えめに強調する。
//

import SwiftUI

struct RankingView: View {
    @EnvironmentObject var setting: Setting
    @StateObject var barChart: BarChartViewModel
    @Environment(\.colorScheme) private var colorScheme
    let height = Double(UIScreen.main.bounds.height)
    let width = Double(UIScreen.main.bounds.width)
    /// メニューへ戻る処理（FileView から渡される）。
    let goBack: () -> Void

    private var brandColor: Color { colorScheme == .dark ? .brandDark : .brandLight }

    init(fileId: String, goBack: @escaping () -> Void) {
        _barChart = StateObject(wrappedValue: BarChartViewModel(fileId: fileId))
        self.goBack = goBack
    }

    /// データ未登録時に表示するサンプル（淡色プレースホルダ）。
    private let blankEntries: [BarEntry] = [
        BarEntry(id: 2, name: String(localized: "Bob"),   value: 500, color: .gray.opacity(0.3)),
        BarEntry(id: 3, name: String(localized: "Casey"), value: 320, color: .gray.opacity(0.3)),
        BarEntry(id: 1, name: String(localized: "Tom"),   value: 230, color: .gray.opacity(0.3)),
        BarEntry(id: 4, name: String(localized: "Brian"), value: 120, color: .gray.opacity(0.3)),
        BarEntry(id: 0, name: String(localized: "Ann"),   value: 80,  color: .gray.opacity(0.3))
    ]

    var body: some View {
        let entries = barChart.entries(sortedBy: .descending)
        let isEmpty = entries.isEmpty
        let displayedEntries = isEmpty ? blankEntries : entries

        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 4) {
                Button(action: { goBack() }, label: {
                    Image(systemName: "list.bullet")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(brandColor)
                        .frame(width: 44, height: 44)
                })
                Spacer()
            }
            .padding(.horizontal, 8)

            HStack(spacing: 6) {
                Text(setting.title)
                    .font(Font.largeTitle.bold())
                    .foregroundColor(brandColor)
            }
            .padding(.top, height * 0.04)
            .padding(.bottom, height * 0.005)

            Spacer(minLength: 0).frame(maxHeight: height * 0.02)

            ScrollView {
                VStack(spacing: 0) {
                    ForEach(Array(displayedEntries.enumerated()), id: \.element.id) { index, entry in
                        rankRow(rank: index + 1, entry: entry, isFirst: index == 0)
                            .opacity(isEmpty ? 0.4 : 1)
                        if index < displayedEntries.count - 1 {
                            Divider()
                                .padding(.leading, width * 0.08 + 44)
                        }
                    }
                }
                .padding(.horizontal, width * 0.08)
                .padding(.bottom, height * 0.04)
            }
        }
        .background(setting.backColor)
    }

    /// ランキング1行。番号 → 色ドット → 名前 → 値。
    /// 1位は番号をブランドカラー＋左アクセントラインで控えめに強調する。
    private func rankRow(rank: Int, entry: BarEntry, isFirst: Bool) -> some View {
        HStack(spacing: 14) {
            // 順位番号（01/02…）。細めのタイポで装飾を抑える。
            Text(String(format: "%02d", rank))
                .font(.system(size: 20, weight: isFirst ? .bold : .regular, design: .rounded))
                .monospacedDigit()
                .foregroundColor(isFirst ? brandColor : setting.textColor.opacity(0.45))
                .frame(width: 40, alignment: .leading)

            Circle()
                .fill(entry.color)
                .frame(width: 10, height: 10)

            Text(entry.name)
                .font(isFirst ? .body.weight(.semibold) : .body)
                .foregroundColor(setting.textColor)
                .lineLimit(1)

            Spacer(minLength: 8)

            Text("\(entry.value)")
                .font(.body.weight(.semibold).monospacedDigit())
                .foregroundColor(setting.textColor)
        }
        .padding(.vertical, 14)
        .overlay(alignment: .leading) {
            // 1位のみ、行の左端に薄いブランドカラーのアクセントライン。
            if isFirst {
                RoundedRectangle(cornerRadius: 2)
                    .fill(brandColor)
                    .frame(width: 3, height: 22)
                    .offset(x: -width * 0.05)
            }
        }
    }
}
