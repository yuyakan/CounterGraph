//
//  BarChart.swift
//  CounterGraph
//
//  Created by 上別縄祐也 on 2022/02/19.
//

import SwiftUI
import Charts


struct BarChartView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var setting: Setting
    @StateObject var barChart: BarChartViewModel
    @Binding var chartType: ChartType
    @State var unit: Int = 10
    @State private var showAddSheet = false
    @State private var showRenameAlert = false
    @State private var draftTitle = ""
    let height = Double(UIScreen.main.bounds.height)
    let width = Double(UIScreen.main.bounds.width)

    init(fileId: String, chartType:  Binding<ChartType>) {
        _barChart = StateObject(wrappedValue: BarChartViewModel(fileId: fileId))
        _chartType = chartType
    }

    /// データ未登録時に表示するサンプル（淡色プレースホルダ）。
    private let blankEntries: [BarEntry] = [
        BarEntry(id: 0, name: String(localized: "Ann"),   value: 80,  color: .gray.opacity(0.3)),
        BarEntry(id: 1, name: String(localized: "Tom"),   value: 230, color: .gray.opacity(0.3)),
        BarEntry(id: 2, name: String(localized: "Bob"),   value: 500, color: .gray.opacity(0.3)),
        BarEntry(id: 3, name: String(localized: "Casey"), value: 320, color: .gray.opacity(0.3)),
        BarEntry(id: 4, name: String(localized: "Brian"), value: 120, color: .gray.opacity(0.3))
    ]

    var body: some View {
        let entries = barChart.entries()
        let isEmpty = entries.isEmpty
        let displayedEntries = isEmpty ? blankEntries : entries

        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 0) {
                Button(action: {
                    dismiss()
                }, label: {
                    Image(systemName: "list.bullet")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(setting.buttonColor)
                        .padding()
                })
                Spacer()
                Button(action: {
                    chartType = .pie
                }, label: {
                    Image(systemName: "chart.pie.fill")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(setting.buttonColor)
                        .padding()
                })
            }

            Button {
                draftTitle = setting.title
                showRenameAlert = true
            } label: {
                HStack(spacing: 6) {
                    Text(setting.title)
                        .font(.largeTitle.bold())
                        .foregroundColor(setting.titleColor)
                    Image(systemName: "pencil")
                        .font(.subheadline)
                        .foregroundColor(setting.titleColor.opacity(0.5))
                }
            }
            .buttonStyle(.plain)
            .padding(.top, height * 0.01)

            // 棒グラフ
            Chart(displayedEntries) { entry in
                BarMark(
                    // X軸は名前ではなく一意なindex。
                    // 名前にすると同名項目が1本の棒に積み上がってしまう。
                    x: .value("Index", String(entry.id)),
                    y: .value("Value", max(entry.value, 0))
                )
                .cornerRadius(6)
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [entry.color, entry.color.opacity(0.55)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .opacity(isEmpty ? 0.5 : 1)
                .annotation(position: .top) {
                    Text("\(entry.value)")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(isEmpty ? setting.textColor.opacity(0.4) : setting.textColor)
                }
            }
            .chartYAxis(.hidden)
            .chartXAxis(.hidden)
            .frame(height: height * 0.28)
            .padding(.horizontal, width * 0.06)
            .padding(.vertical, height * 0.02)

            // 各項目の行（名前＋値＋±ボタン）。編集モードなしで常時カウント可能。
            // 左スワイプで削除（List の swipeActions）。
            List {
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
                            .font(.body.weight(.semibold).monospacedDigit())
                            .foregroundColor(setting.textColor)
                            .frame(minWidth: 56, alignment: .trailing)

                        if !isEmpty {
                            Button {
                                barChart.minus(index: entry.id, value: unit)
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(setting.buttonColor)
                            }
                            .buttonStyle(.plain)
                            Button {
                                barChart.plus(index: entry.id, value: unit)
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(setting.buttonColor)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .opacity(isEmpty ? 0.4 : 1)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 8, leading: width * 0.06, bottom: 8, trailing: width * 0.06))
                    .swipeActions(edge: .trailing) {
                        if !isEmpty {
                            Button(role: .destructive) {
                                barChart.removeData(index: entry.id)
                            } label: {
                                Label(String(localized: "Delete"), systemImage: "trash")
                            }
                        }
                    }
                }
                Color.clear
                    .frame(height: height * 0.02)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)

            // 増減単位の設定＋新規項目追加
            HStack(spacing: 16) {
                HStack(spacing: 6) {
                    Text(LocalizedStringKey("1unit:"))
                        .font(.subheadline)
                        .foregroundColor(setting.textColor.opacity(0.7))
                    TextField("", value: $unit, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                        .frame(width: 60)
                }
                Spacer()
                Button {
                    showAddSheet = true
                } label: {
                    Label(String(localized: "Add"), systemImage: "plus.circle.fill")
                        .font(.body.weight(.semibold))
                        .foregroundColor(setting.buttonColor)
                }
            }
            .padding(.horizontal, width * 0.06)
            .padding(.vertical, 10)
        }
        .background(setting.backColor)
        .sheet(isPresented: $showAddSheet) {
            AddItemSheet(barChart: barChart, buttonColor: setting.buttonColor)
                .presentationDetents([.height(220)])
        }
        .alert(isPresented: $barChart.isShowAlert) { barChart.alert() }
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

/// 新規項目を追加するためのシート。
private struct AddItemSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var barChart: BarChartViewModel
    let buttonColor: Color

    var body: some View {
        NavigationStack {
            Form {
                TextField(String(localized: "Jack"), text: $barChart.name)
                TextField(String(localized: "Value"), value: $barChart.value, format: .number)
                    .keyboardType(.numberPad)
            }
            .navigationTitle(String(localized: "Add"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Add")) {
                        barChart.addData()
                        dismiss()
                    }
                    .disabled(barChart.name.isEmpty)
                }
            }
        }
    }
}
