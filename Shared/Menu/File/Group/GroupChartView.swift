//
//  GroupChartView.swift
//  CounterGraph
//
//  グループタブ。グループごとの合計をグループ色の棒で表示する。
//  編集モードでグループの作成・削除と、各項目のグループ割当を行う。
//

import SwiftUI
import Charts

struct GroupChartView: View {
    @EnvironmentObject var setting: Setting
    @StateObject private var model: GroupChartViewModel
    @StateObject private var groupStore: GroupStore
    @Environment(\.colorScheme) private var colorScheme
    @State private var isEditing = false
    @State private var showAddGroupAlert = false
    @State private var newGroupName = ""
    let height = Double(UIScreen.main.bounds.height)
    let width = Double(UIScreen.main.bounds.width)
    /// メニューへ戻る処理（FileView から渡される）。
    let goBack: () -> Void

    private var brandColor: Color { colorScheme == .dark ? .brandDark : .brandLight }

    /// iPad ではラベル・数値を少し大きく表示するための倍率。iPhone は等倍。
    private var deviceScale: CGFloat {
        UIDevice.current.userInterfaceIdiom == .pad ? 1.5 : 1.0
    }

    init(fileId: String, goBack: @escaping () -> Void) {
        _model = StateObject(wrappedValue: GroupChartViewModel(fileId: fileId))
        _groupStore = StateObject(wrappedValue: GroupStore(fileId: fileId))
        self.goBack = goBack
    }

    var body: some View {
        let groups = groupStore.groups
        let bars = model.groupBars(groups: groups)
        let hasGroups = !groups.isEmpty

        VStack(spacing: 0) {
            header

            title

            if isEditing {
                editContent(groups: groups)
            } else if hasGroups {
                chart(bars: bars)
                Spacer()
            } else {
                emptyPlaceholder
                Spacer()
            }
        }
        .background(setting.backColor)
        .onAppear {
            model.reload()
            groupStore.reload()
        }
        .alert(String(localized: "newGroup"), isPresented: $showAddGroupAlert) {
            TextField(String(localized: "groupName"), text: $newGroupName)
            Button(String(localized: "Cancel"), role: .cancel) { newGroupName = "" }
            Button(String(localized: "Add")) {
                let trimmed = newGroupName.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty { groupStore.add(name: trimmed) }
                newGroupName = ""
            }
        }
    }

    // MARK: - Header / Title

    private var header: some View {
        HStack(alignment: .center, spacing: 4) {
            Button(action: { goBack() }, label: {
                Image(systemName: "list.bullet")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(brandColor)
                    .frame(width: 44, height: 44)
            })
            Spacer()
            Button(action: { withAnimation { isEditing.toggle() } }, label: {
                Text(isEditing ? String(localized: "Done") : String(localized: "Edit"))
                    .font(.body.weight(.semibold))
                    .foregroundColor(brandColor)
                    .frame(height: 44)
                    .padding(.horizontal, 8)
            })
        }
        .padding(.horizontal, 8)
    }

    private var title: some View {
        HStack(spacing: 6) {
            Text(setting.title)
                .font((isEditing ? Font.title : Font.largeTitle).bold())
                .foregroundColor(brandColor)
        }
        .padding(.top, height * (isEditing ? 0.015 : 0.04))
        .padding(.bottom, height * (isEditing ? 0.01 : 0.005))
    }

    // MARK: - Display

    /// グループ合計の棒グラフ（グループ色のグラデーション縦棒）。
    /// グループ名は棒グラフタブと同じく棒の直下に斜め45度で表示する。
    private func chart(bars: [GroupBar]) -> some View {
        // 斜めラベルの最大幅（これを超える名前は2行に折り返す）と、必要な高さ・フォントサイズ。
        let labelFont = groupLabelFontSize
        let labelMaxWidth = width * 0.28
        let labelHeight = estimatedDiagonalLabelHeight(names: bars.map { $0.name },
                                                       fontSize: labelFont,
                                                       maxWidth: labelMaxWidth)

        return Chart(bars) { bar in
            BarMark(
                x: .value("Group", bar.id),
                y: .value("Total", max(bar.value, 0)),
                width: .ratio(0.5)
            )
            .cornerRadius(10)
            .foregroundStyle(
                LinearGradient(colors: [bar.color, bar.color.opacity(0.5)],
                               startPoint: .top, endPoint: .bottom)
            )
            .annotation(position: .top, spacing: 6) {
                Text("\(bar.value)")
                    .font(.system(size: 16 * deviceScale, weight: .bold, design: .rounded))
                    .foregroundColor(setting.textColor)
            }
        }
        // 軸は非表示にし、名前は棒の直下へ斜め45度で自前オーバーレイ表示する。
        .chartYAxis(.hidden)
        .chartXAxis(.hidden)
        .chartXScale(range: .plotDimension(padding: 0))
        .overlay(alignment: .topLeading) {
            GeometryReader { geo in
                ForEach(bars) { bar in
                    DiagonalLabel(text: bar.name, color: setting.textColor,
                                  maxWidth: labelMaxWidth, fontSize: labelFont)
                        .offset(x: barCenterX(id: bar.id, in: bars, width: geo.size.width),
                                y: geo.size.height + 4)
                }
            }
        }
        .frame(height: height * 0.5)
        .padding(.horizontal, width * 0.08)
        .padding(.bottom, labelHeight)
        .padding(.vertical, height * 0.02)
    }

    /// 斜めラベルのフォントサイズ（iPad では拡大）。
    private var groupLabelFontSize: CGFloat { 14 * deviceScale }

    /// カテゴリ軸で等間隔に並ぶ棒の中心X座標（プロット幅 width 内）。
    private func barCenterX(id: String, in bars: [GroupBar], width: CGFloat) -> CGFloat {
        guard let idx = bars.firstIndex(where: { $0.id == id }), !bars.isEmpty else { return 0 }
        let step = width / CGFloat(bars.count)
        return step * (CGFloat(idx) + 0.5)
    }

    private var emptyPlaceholder: some View {
        VStack(spacing: 12) {
            Image(systemName: "square.grid.2x2")
                .font(.system(size: 44))
                .foregroundColor(brandColor.opacity(0.4))
            Text(String(localized: "noGroupsYet"))
                .font(.body)
                .foregroundColor(setting.textColor.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .padding(.top, height * 0.06)
        .padding(.horizontal, width * 0.1)
    }

    // MARK: - Edit

    /// 編集モード: グループ一覧（作成・削除）と、各項目のグループ割当。
    private func editContent(groups: [CountGroup]) -> some View {
        List {
            Section(String(localized: "groups")) {
                ForEach(groups) { group in
                    HStack(spacing: 12) {
                        Circle().fill(group.color).frame(width: 16, height: 16)
                        Text(group.name)
                            .foregroundColor(setting.textColor)
                        Spacer()
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            model.detachItems(fromGroupId: group.id)
                            groupStore.remove(id: group.id)
                        } label: {
                            Label(String(localized: "Delete"), systemImage: "trash")
                        }
                    }
                }
                Button {
                    showAddGroupAlert = true
                } label: {
                    Label(String(localized: "newGroup"), systemImage: "plus.circle.fill")
                        .foregroundColor(brandColor)
                }
            }

            Section(String(localized: "assignItems")) {
                ForEach(model.items()) { item in
                    HStack(spacing: 12) {
                        Text(item.name)
                            .foregroundColor(setting.textColor)
                            .lineLimit(1)
                        Spacer(minLength: 8)
                        // 所属グループを選ぶメニュー。
                        Menu {
                            Button(String(localized: "noGroup")) {
                                model.setGroup(index: item.id, groupId: nil)
                            }
                            ForEach(groups) { group in
                                Button {
                                    model.setGroup(index: item.id, groupId: group.id)
                                } label: {
                                    if item.groupId == group.id {
                                        Label(group.name, systemImage: "checkmark")
                                    } else {
                                        Text(group.name)
                                    }
                                }
                            }
                        } label: {
                            HStack(spacing: 6) {
                                if let group = groupStore.group(id: item.groupId) {
                                    Circle().fill(group.color).frame(width: 12, height: 12)
                                    Text(group.name)
                                } else {
                                    Text(String(localized: "noGroup"))
                                        .foregroundColor(.secondary)
                                }
                                Image(systemName: "chevron.up.chevron.down")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
    }
}
