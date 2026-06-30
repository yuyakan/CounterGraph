//
//  PieChart.swift
//  CounterGraph
//
//  Created by 上別縄祐也 on 2023/11/10.
//

import SwiftUI
import Charts

struct PieChartView: View {
    @EnvironmentObject var setting: Setting
    @StateObject var pieChart: PieChartViewModel
    @Binding var chartType: ChartType
    @ObservedObject var interstitial: Interstitial
    let height = Double(UIScreen.main.bounds.height)
    let width = Double(UIScreen.main.bounds.width)
    @Environment(\.colorScheme) private var colorScheme
    @State private var isEditing = false
    @State private var showRenameAlert = false
    @State private var draftTitle = ""
    /// メニューへ戻る処理（FileView から渡される）。
    let goBack: () -> Void

    private var brandColor: Color { colorScheme == .dark ? .brandDark : .brandLight }

    init (fileId: String, chartType: Binding<ChartType>, interstitial: Interstitial, goBack: @escaping () -> Void){
        _pieChart = StateObject(wrappedValue: PieChartViewModel(fileId: fileId))
        _chartType = chartType
        self.goBack = goBack
        self.interstitial = interstitial
    }

    /// データ未登録時に表示するサンプルの扇形。
    private let blankEntries: [SectorEntry] = [
        SectorEntry(id: 0, name: String(localized: "Ann"),   value: 80,  color: .gray.opacity(0.2), percent: "6.4%"),
        SectorEntry(id: 1, name: String(localized: "Tom"),   value: 230, color: .gray.opacity(0.3), percent: "18.4%"),
        SectorEntry(id: 2, name: String(localized: "Bob"),   value: 500, color: .gray.opacity(0.2), percent: "40.0%"),
        SectorEntry(id: 3, name: String(localized: "Casey"), value: 320, color: .gray.opacity(0.3), percent: "25.6%"),
        SectorEntry(id: 4, name: String(localized: "Brian"), value: 120, color: .gray.opacity(0.2), percent: "9.6%")
    ]

    var body: some View {
        let entries = pieChart.entries()
        let isEmpty = entries.isEmpty
        let displayedEntries = isEmpty ? blankEntries : entries
        let total = displayedEntries.reduce(0) { $0 + $1.value }

        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 0) {
                Button(action: {
                    goBack()
                }, label: {
                    Image(systemName: "list.bullet")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(brandColor)
                        .padding()
                })
                Spacer()
                Button(action: {
                    chartType = .bar
                }, label: {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(brandColor)
                        .padding(.vertical)
                })
                Button(action: {
                    withAnimation { isEditing.toggle() }
                }, label: {
                    Text(isEditing ? String(localized: "Done") : String(localized: "Edit"))
                        .font(.body.weight(.semibold))
                        .foregroundColor(brandColor)
                        .padding()
                })
            }

            HStack(spacing: 6) {
                Text(setting.title)
                    .font(.largeTitle.bold())
                    .foregroundColor(brandColor)
                if isEditing {
                    Image(systemName: "pencil")
                        .font(.subheadline)
                        .foregroundColor(brandColor.opacity(0.5))
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                guard isEditing else { return }
                draftTitle = setting.title
                showRenameAlert = true
            }
            .padding(.top, height * 0.035)
            .padding(.bottom, height * 0.01)

            // ドーナツチャート＋中央に合計値
            Chart(displayedEntries) { entry in
                SectorMark(
                    angle: .value("Value", entry.value),
                    innerRadius: .ratio(0.62),
                    angularInset: 1.5
                )
                .cornerRadius(4)
                .foregroundStyle(entry.color)
                .opacity(isEmpty ? 0.5 : 1)
            }
            .chartLegend(.hidden)
            .frame(width: width * 0.72, height: width * 0.72)
            .overlay {
                VStack(spacing: 2) {
                    Text(LocalizedStringKey("Total"))
                        .font(.subheadline)
                        .foregroundColor(setting.textColor.opacity(0.6))
                    Text("\(total)")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(setting.textColor)
                }
            }
            .padding(.vertical, height * 0.02)

            // 凡例（色チップ＋名前＋値＋パーセント）
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(displayedEntries) { entry in
                        HStack(spacing: 12) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(entry.color)
                                .frame(width: 16, height: 16)
                            Text(LocalizedStringKey(entry.name))
                                .font(.body)
                                .foregroundColor(setting.textColor)
                                .lineLimit(1)
                            Spacer()
                            Text("\(entry.value)")
                                .font(.body.weight(.semibold))
                                .foregroundColor(setting.textColor)
                            Text(entry.percent)
                                .font(.subheadline)
                                .foregroundColor(setting.textColor.opacity(0.6))
                                .frame(width: 56, alignment: .trailing)
                        }
                        .padding(.vertical, 10)
                        .opacity(isEmpty ? 0.4 : 1)
                        Divider()
                    }
                }
                .padding(.horizontal, width * 0.08)
                .padding(.bottom, height * 0.04)
            }
        }
        .onAppear(){
            interstitial.presentInterstitial()
        }
        .onDisappear(perform: {
            pieChart.save()
        })
        .background(setting.backColor)
        .alert(String(localized: "title"), isPresented: $showRenameAlert) {
            TextField("", text: $draftTitle)
            Button(String(localized: "Cancel"), role: .cancel) {}
            Button("OK") {
                let trimmed = draftTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty {
                    setting.title = trimmed
                    setting.save()
                }
            }
        }
    }
}

