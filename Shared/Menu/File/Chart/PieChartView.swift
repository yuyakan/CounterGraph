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
    @StateObject var countUnit: CountUnit
    @StateObject private var nameTemplates = NameTemplateStore()
    @EnvironmentObject var interstitial: Interstitial
    @EnvironmentObject var adCounter: AdCounter
    let height = Double(UIScreen.main.bounds.height)
    let width = Double(UIScreen.main.bounds.width)
    @Environment(\.colorScheme) private var colorScheme
    @State private var sortOrder: ChartSortOrder = .entry
    @State private var isEditing = false
    @State private var showRenameAlert = false
    @State private var draftTitle = ""
    @State private var showAddSheet = false
    /// 編集シートを開いている項目の index（nil で非表示）。
    @State private var editingEntryID: Int?
    /// メニューへ戻る処理（FileView から渡される）。
    let goBack: () -> Void

    private var brandColor: Color { colorScheme == .dark ? .brandDark : .brandLight }

    init (fileId: String, goBack: @escaping () -> Void){
        _pieChart = StateObject(wrappedValue: PieChartViewModel(fileId: fileId))
        _countUnit = StateObject(wrappedValue: CountUnit(fileId: fileId))
        self.goBack = goBack
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
        let entries = pieChart.entries(sortedBy: sortOrder)
        let isEmpty = entries.isEmpty
        let displayedEntries = isEmpty ? blankEntries : entries
        let total = displayedEntries.reduce(0) { $0 + $1.value }

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
                    // 編集モードから「完了」を押したときにカウントし、条件を満たせば広告を表示する。
                    let wasEditing = isEditing
                    withAnimation { isEditing.toggle() }
                    if wasEditing {
                        adCounter.increment(by: 2)   // 編集完了は2回分
                        interstitial.presentIfReady(counter: adCounter)
                    }
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
            .padding(.top, height * (isEditing ? 0.015 : 0.04))
            .padding(.bottom, height * (isEditing ? 0.01 : 0.005))

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
            // 編集モードは下の編集リストへ場所を譲るためドーナツを小さくする。
            .frame(width: width * (isEditing ? 0.44 : 0.72),
                   height: width * (isEditing ? 0.44 : 0.72))
            .overlay {
                VStack(spacing: 2) {
                    Text(LocalizedStringKey("Total"))
                        .font(.subheadline)
                        .foregroundColor(setting.textColor.opacity(0.6))
                    Text("\(total)")
                        .font(.system(size: isEditing ? 28 : 40, weight: .bold, design: .rounded))
                        .foregroundColor(setting.textColor)
                }
            }
            .padding(.vertical, height * (isEditing ? 0.01 : 0.02))

            if isEditing {
                // 編集モード: 名前・値をタップで編集シート、±ボタンでカウント、左スワイプで削除。
                // プレースホルダー（blankEntries）は表示せず実データ(entries)のみ並べる。
                List {
                    ForEach(entries) { entry in
                        HStack(spacing: 12) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(entry.color)
                                .frame(width: 16, height: 16)
                            // 名前・値はタップで専用シートを開いて編集（キーボードに隠れない）
                            Button {
                                editingEntryID = entry.id
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

                            Button {
                                pieChart.minus(index: entry.id, value: countUnit.value)
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(brandColor)
                            }
                            .buttonStyle(.plain)
                            Button {
                                pieChart.plus(index: entry.id, value: countUnit.value)
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(brandColor)
                            }
                            .buttonStyle(.plain)
                        }
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 4, leading: width * 0.06, bottom: 4, trailing: width * 0.06))
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                pieChart.removeData(index: entry.id)
                            } label: {
                                Label(String(localized: "Delete"), systemImage: "trash")
                            }
                        }
                    }

                    // 項目リストの最下部に「＋ 項目を追加」行を置く（カウント幅とは独立）。
                    Button {
                        showAddSheet = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 22))
                                .foregroundColor(brandColor)
                            Text(String(localized: "Add"))
                                .font(.body.weight(.semibold))
                                .foregroundColor(brandColor)
                            Spacer()
                        }
                    }
                    .buttonStyle(.plain)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 8, leading: width * 0.06, bottom: 4, trailing: width * 0.06))
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)

                // カウント幅の設定（編集モードのみ）。
                CountUnitPicker(unit: countUnit, tint: brandColor)
                    .padding(.horizontal, width * 0.06)
                    .padding(.vertical, 10)
            } else {
                // 表示モード: 凡例（色チップ＋名前＋値＋パーセント）
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(displayedEntries) { entry in
                            HStack(spacing: 12) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(entry.color)
                                    .frame(width: 16, height: 16)
                                Text(entry.name)
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
        }
        .onAppear(){
            // 他タブ（棒グラフ等）での変更を反映するため最新データを読み直す。
            pieChart.reload()
        }
        .onDisappear(perform: {
            pieChart.save()
        })
        .background(setting.backColor)
        .sheet(isPresented: $showAddSheet) {
            AddItemSheet(name: $pieChart.name,
                         value: $pieChart.value,
                         templates: nameTemplates,
                         buttonColor: brandColor,
                         onAdd: { pieChart.addData() })
                .presentationDetents([.medium])
        }
        // 名前・値の編集シート（キーボードはシート内に出るため隠れ問題が起きない）
        .sheet(item: Binding(
            get: { editingEntryID.map { EditTarget(id: $0) } },
            set: { editingEntryID = $0?.id }
        )) { target in
            ItemEditSheet(
                initialName: pieChart.name(index: target.id),
                initialValue: Int(pieChart.value(index: target.id)),
                buttonColor: brandColor,
                onSave: { name, value in
                    pieChart.updateName(index: target.id, name: name)
                    pieChart.updateValue(index: target.id, value: value)
                }
            )
            .presentationDetents([.height(260)])
        }
        .alert(isPresented: $pieChart.isShowAlert) { pieChart.alert() }
        .alert(String(localized: "title"), isPresented: $showRenameAlert) {
            TextField("", text: $draftTitle)
            Button(String(localized: "Cancel"), role: .cancel) {}
            Button("OK") {
                // 空タイトルも許容する（前後の空白は除去してから保存）。
                setting.title = draftTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                setting.save()
            }
        }
    }
}

