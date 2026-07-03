//
//  BarChart.swift
//  CounterGraph
//
//  Created by 上別縄祐也 on 2022/02/19.
//

import SwiftUI
import Charts


struct BarChartView: View {
    @EnvironmentObject var setting: Setting
    @Environment(\.colorScheme) private var colorScheme
    @StateObject var barChart: BarChartViewModel
    @Binding var chartType: ChartType
    @Binding var orientation: BarOrientation
    @State var unit: Int = 10
    @State private var sortOrder: ChartSortOrder = .entry
    @State private var isEditing = false
    @State private var showAddSheet = false
    @State private var showRenameAlert = false
    @State private var draftTitle = ""
    /// 編集シートを開いている項目の index（nil で非表示）。
    @State private var editingEntryID: Int?
    let height = Double(UIScreen.main.bounds.height)
    let width = Double(UIScreen.main.bounds.width)
    /// メニューへ戻る処理（FileView から渡される）。
    let goBack: () -> Void

    private var brandColor: Color { colorScheme == .dark ? .brandDark : .brandLight }

    /// グラフの高さ比率。編集モードは編集領域を広げるため小さめ、表示モードは大きめ（横棒はさらに大きく）。
    private var chartHeightRatio: CGFloat {
        if isEditing { return 0.26 }
        return orientation == .horizontal ? 0.55 : 0.46
    }

    /// カテゴリ軸で等間隔に並ぶ棒の中心X座標（プロット幅 width 内）。
    private func barCenterX(id: Int, in entries: [BarEntry], width: CGFloat) -> CGFloat {
        guard let idx = entries.firstIndex(where: { $0.id == id }), !entries.isEmpty else { return 0 }
        let step = width / CGFloat(entries.count)
        return step * (CGFloat(idx) + 0.5)
    }

    /// 名前ラベルのフォントサイズを項目数でスケールする（少ないほど大きく）。下限・上限あり。
    private func labelFontSize(count: Int) -> CGFloat {
        let maxSize: CGFloat = 17   // 項目が少ないとき（上限）
        let minSize: CGFloat = 11   // 項目が多いとき（下限）
        let fewCount = 3            // これ以下は maxSize
        let manyCount = 10          // これ以上は minSize
        if count <= fewCount { return maxSize }
        if count >= manyCount { return minSize }
        let t = CGFloat(count - fewCount) / CGFloat(manyCount - fewCount)
        return maxSize - (maxSize - minSize) * t
    }

    /// 斜め45度で表示する名前ラベルに必要な縦方向の高さ。
    /// 表示中の最長の名前を実測し、maxWidth で頭打ち（＝2行折り返し）した幅・高さから求める。
    private func diagonalLabelHeight(for entries: [BarEntry], maxWidth: CGFloat) -> CGFloat {
        let font = UIFont.systemFont(ofSize: labelFontSize(count: entries.count))
        let attrs: [NSAttributedString.Key: Any] = [.font: font]
        let rawMaxWidth = entries
            .map { ($0.name as NSString).size(withAttributes: attrs).width }
            .max() ?? 0
        // maxWidth を超える名前は2行に折り返るため、幅は頭打ち・行数は最大2行で見積もる。
        let effectiveWidth = min(rawMaxWidth, maxWidth)
        let lines: CGFloat = rawMaxWidth > maxWidth ? 2 : 1
        let textHeight = font.lineHeight * lines
        // 45度回転後の外接矩形の高さ = (幅 + 高さ) / √2 ＋ 余白
        return (effectiveWidth + textHeight) / 1.41421356 + 8
    }

    init(fileId: String, chartType: Binding<ChartType>, orientation: Binding<BarOrientation>, goBack: @escaping () -> Void) {
        _barChart = StateObject(wrappedValue: BarChartViewModel(fileId: fileId))
        _chartType = chartType
        _orientation = orientation
        self.goBack = goBack
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
        let entries = barChart.entries(sortedBy: sortOrder)
        let isEmpty = entries.isEmpty
        let displayedEntries = isEmpty ? blankEntries : entries
        // 軸の index("0","1"...) から名前へ変換する辞書。棒の直下/横に名前を表示するために使う。
        let nameByID = Dictionary(uniqueKeysWithValues: displayedEntries.map { (String($0.id), $0.name) })
        // 縦棒の斜めラベルの最大幅（これを超える名前は2行に折り返す）と、必要な高さ・フォントサイズ。
        let labelMaxWidth = width * 0.28
        let labelFont = labelFontSize(count: displayedEntries.count)
        let labelHeight = diagonalLabelHeight(for: displayedEntries, maxWidth: labelMaxWidth)

        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 4) {
                Button(action: {
                    goBack()
                }, label: {
                    Image(systemName: "list.bullet")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(brandColor)
                        .frame(width: 44, height: 44)
                })
                Spacer()
                // 現在の形式以外の2つへ直接切り替える
                Button(action: {
                    withAnimation {
                        orientation = (orientation == .vertical) ? .horizontal : .vertical
                    }
                }, label: {
                    Image(systemName: orientation == .vertical ? "text.alignleft" : "chart.bar.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(brandColor)
                        .frame(width: 44, height: 44)
                })
                Button(action: {
                    chartType = .pie
                }, label: {
                    Image(systemName: "chart.pie.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(brandColor)
                        .frame(width: 44, height: 44)
                })
                Menu {
                    Picker("", selection: $sortOrder) {
                        ForEach(ChartSortOrder.allCases) { order in
                            Label(order.label, systemImage: order.systemImage).tag(order)
                        }
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(brandColor)
                        .frame(width: 44, height: 44)
                }
                Button(action: {
                    withAnimation { isEditing.toggle() }
                }, label: {
                    Text(isEditing ? String(localized: "Done") : String(localized: "Edit"))
                        .font(.body.weight(.semibold))
                        .foregroundColor(brandColor)
                        .frame(height: 44)
                        .padding(.horizontal, 8)
                })
            }
            .padding(.horizontal, 8)

            HStack(spacing: 6) {
                Text(setting.title)
                    .font((isEditing ? Font.title : Font.largeTitle).bold())
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
            .padding(.top, height * (isEditing ? 0.015 : 0.06))
            .padding(.bottom, height * 0.01)

            // 表示モードはタイトルとグラフの間に控えめな余白を入れつつ、
            // 下側を Spacer で広めに取ってグラフをやや中央寄り〜下寄りに配置する。
            if !isEditing { Spacer(minLength: 0).frame(maxHeight: height * 0.04) }

            // 棒グラフ（縦棒 / 横棒）。X/Y は一意な index を軸にし、同名項目が積み上がるのを防ぐ。
            Chart(displayedEntries) { entry in
                if orientation == .vertical {
                    BarMark(
                        x: .value("Index", String(entry.id)),
                        y: .value("Value", max(entry.value, 0))
                    )
                    .cornerRadius(6)
                    .foregroundStyle(
                        LinearGradient(colors: [entry.color, entry.color.opacity(0.55)],
                                       startPoint: .top, endPoint: .bottom)
                    )
                    .opacity(isEmpty ? 0.5 : 1)
                    .annotation(position: .top) {
                        Text("\(entry.value)")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(isEmpty ? setting.textColor.opacity(0.4) : setting.textColor)
                    }
                } else {
                    BarMark(
                        x: .value("Value", max(entry.value, 0)),
                        y: .value("Index", String(entry.id))
                    )
                    .cornerRadius(6)
                    .foregroundStyle(
                        LinearGradient(colors: [entry.color, entry.color.opacity(0.55)],
                                       startPoint: .leading, endPoint: .trailing)
                    )
                    .opacity(isEmpty ? 0.5 : 1)
                    .annotation(position: .trailing) {
                        Text("\(entry.value)")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(isEmpty ? setting.textColor.opacity(0.4) : setting.textColor)
                    }
                }
            }
            // 縦棒: 軸は両方非表示（名前は自前オーバーレイで斜め表示、値は棒の上に表示）。
            // 横棒: Y軸(カテゴリ)に名前を表示、X軸(値)は非表示。
            .chartXAxis(.hidden)
            .chartYAxis {
                if orientation == .horizontal {
                    AxisMarks(position: .leading) { value in
                        AxisValueLabel {
                            if let key = value.as(String.self), let name = nameByID[key] {
                                Text(name)
                                    .font(.caption)
                                    .foregroundColor(setting.textColor)
                            }
                        }
                    }
                }
            }
            // 縦棒の名前は棒の直下に斜め45度で重ねる。
            // AxisValueLabel は回転後の外接矩形をレイアウトに確保できず隣の棒と衝突するため、
            // chartXAxis を使わず overlay + プロット座標で各棒の真下に配置する。
            .chartXScale(range: .plotDimension(padding: 0))
            .overlay(alignment: .topLeading) {
                if orientation == .vertical {
                    GeometryReader { geo in
                        ForEach(displayedEntries) { entry in
                            DiagonalLabel(text: entry.name, color: setting.textColor, maxWidth: labelMaxWidth, fontSize: labelFont)
                                // 各棒の中心・プロット下端を基準に、右下へ斜めに垂らす
                                .offset(x: barCenterX(id: entry.id, in: displayedEntries, width: geo.size.width),
                                        y: geo.size.height + 4)
                        }
                    }
                }
            }
            // 横棒は項目が縦に積まれるため、表示モードでは高さを大きめに取る。
            .frame(height: height * chartHeightRatio)
            .padding(.horizontal, width * 0.06)
            .padding(.bottom, orientation == .vertical ? labelHeight : 0)
            .padding(.vertical, height * 0.015)

            if isEditing {
                // 編集モード: 名前・値をタップで編集シート、±ボタン、左スワイプで削除
                List {
                    ForEach(displayedEntries) { entry in
                        HStack(spacing: 12) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(entry.color)
                                .frame(width: 16, height: 16)
                            // 名前・値はタップで専用シートを開いて編集（キーボードに隠れない）
                            Button {
                                if !isEmpty { editingEntryID = entry.id }
                            } label: {
                                HStack(spacing: 8) {
                                    Text(entry.name)
                                        .font(.body)
                                        .foregroundColor(setting.textColor)
                                        .lineLimit(2)
                                        .multilineTextAlignment(.leading)
                                        .fixedSize(horizontal: false, vertical: true)
                                    Spacer(minLength: 8)
                                    Text("\(entry.value)")
                                        .font(.body.weight(.semibold).monospacedDigit())
                                        .foregroundColor(setting.textColor)
                                        .layoutPriority(1)
                                    Image(systemName: "pencil")
                                        .font(.footnote)
                                        .foregroundColor(brandColor.opacity(0.6))
                                }
                            }
                            .buttonStyle(.plain)
                            .disabled(isEmpty)

                            if !isEmpty {
                                Button {
                                    barChart.minus(index: entry.id, value: unit)
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.system(size: 28))
                                        .foregroundColor(brandColor)
                                }
                                .buttonStyle(.plain)
                                Button {
                                    barChart.plus(index: entry.id, value: unit)
                                } label: {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 28))
                                        .foregroundColor(brandColor)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 4, leading: width * 0.06, bottom: 4, trailing: width * 0.06))
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
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            } else {
                // 表示モード: 名前は棒の下(軸)に表示済みのため凡例は不要
                Spacer()
            }

            // 増減単位の設定＋新規項目追加（編集モードのみ）
            if isEditing {
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
                            .foregroundColor(brandColor)
                    }
                }
                .padding(.horizontal, width * 0.06)
                .padding(.vertical, 10)
            }
        }
        .background(setting.backColor)
        .sheet(isPresented: $showAddSheet) {
            AddItemSheet(barChart: barChart, buttonColor: brandColor)
                .presentationDetents([.height(220)])
        }
        // 名前・値の編集シート（キーボードはシート内に出るため隠れ問題が起きない）
        .sheet(item: Binding(
            get: { editingEntryID.map { EditTarget(id: $0) } },
            set: { editingEntryID = $0?.id }
        )) { target in
            ItemEditSheet(
                initialName: barChart.name(index: target.id),
                initialValue: Int(barChart.value(index: target.id)),
                buttonColor: brandColor,
                onSave: { name, value in
                    barChart.updateName(index: target.id, name: name)
                    barChart.updateValue(index: target.id, value: value)
                }
            )
            .presentationDetents([.height(260)])
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

/// 棒の直下に斜め45度で表示する名前ラベル。
/// 起点(offsetで指定した棒の中心・下端)から右下へ文字を垂らす。
/// maxWidth を超える名前は2行まで折り返す。
private struct DiagonalLabel: View {
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

/// 編集対象の項目（sheet(item:) 用の Identifiable ラッパ）。
private struct EditTarget: Identifiable { let id: Int }

/// 既存項目の名前・値を編集するシート。
private struct ItemEditSheet: View {
    @Environment(\.dismiss) var dismiss
    let initialName: String
    let initialValue: Int
    let buttonColor: Color
    let onSave: (String, Int) -> Void

    @State private var name: String
    @State private var value: Int
    @FocusState private var nameFocused: Bool

    init(initialName: String, initialValue: Int, buttonColor: Color, onSave: @escaping (String, Int) -> Void) {
        self.initialName = initialName
        self.initialValue = initialValue
        self.buttonColor = buttonColor
        self.onSave = onSave
        _name = State(initialValue: initialName)
        _value = State(initialValue: initialValue)
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField(String(localized: "Jack"), text: $name)
                    .focused($nameFocused)
                TextField(String(localized: "Value"), value: $value, format: .number)
                    .keyboardType(.numberPad)
            }
            .navigationTitle(String(localized: "Edit"))
            .navigationBarTitleDisplayMode(.inline)
            // シート表示時に名前フィールドへ自動でカーソルを当てキーボードを表示する
            .task {
                try? await Task.sleep(nanoseconds: 300_000_000)
                nameFocused = true
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Done")) {
                        onSave(name, value)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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
