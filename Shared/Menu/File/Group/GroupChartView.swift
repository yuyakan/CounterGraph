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
    /// 既存の棒グラフとトーンを揃えつつ、角丸を大きめ・値ラベルを rounded にしてモダンに。
    private func chart(bars: [GroupBar]) -> some View {
        // 同名グループでも一意に並ぶよう、棒はグループIDを軸にし、名前は自前ラベルで表示する。
        let nameByID = Dictionary(uniqueKeysWithValues: bars.map { ($0.id, $0.name) })
        let colorByID = Dictionary(uniqueKeysWithValues: bars.map { ($0.id, $0.color) })

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
                    .font(.system(.callout, design: .rounded).weight(.bold))
                    .foregroundColor(setting.textColor)
            }
        }
        .chartYAxis(.hidden)
        .chartXAxis {
            AxisMarks { value in
                AxisValueLabel {
                    if let id = value.as(String.self) {
                        HStack(spacing: 5) {
                            Circle()
                                .fill(colorByID[id] ?? .gray)
                                .frame(width: 8, height: 8)
                            Text(nameByID[id] ?? "")
                                .font(.footnote.weight(.medium))
                                .foregroundColor(setting.textColor)
                                .lineLimit(1)
                        }
                    }
                }
            }
        }
        .frame(height: height * 0.5)
        .padding(.horizontal, width * 0.08)
        .padding(.vertical, height * 0.02)
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
