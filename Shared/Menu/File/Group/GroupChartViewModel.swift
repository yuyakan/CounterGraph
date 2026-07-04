//
//  GroupChartViewModel.swift
//  CounterGraph
//
//  グループごとの合計を計算し、グループタブの棒グラフ・割当UIへ供給する。
//

import SwiftUI

/// グループ集計の棒1本分。
struct GroupBar: Identifiable {
    let id: String       // グループID
    let name: String
    let value: Int       // グループ内の項目値の合計
    let color: Color
}

/// グループ割当UI用の項目1件。
struct GroupItem: Identifiable {
    let id: Int          // dataList 内の index
    let name: String
    let value: Int
    let groupId: String?
}

final class GroupChartViewModel: ObservableObject {
    @Published private var dataList: DataList

    init(fileId: String) {
        self.dataList = DataList(fileId: fileId)
    }

    /// UserDefaults から最新のデータを読み直す。
    func reload() {
        dataList = DataList(fileId: dataList.fileId)
        objectWillChange.send()
    }

    /// 項目一覧（割当UI用）。
    func items() -> [GroupItem] {
        (0..<dataList.count()).map { index in
            GroupItem(id: index,
                      name: dataList.name(index: index),
                      value: dataList.value(index: index),
                      groupId: dataList.groupId(index: index))
        }
    }

    /// グループごとの合計棒。groups の順で並べ、値0でも表示する。
    /// 「グループなし」の項目は集計に含めない（グループ化されたものだけ見せる）。
    func groupBars(groups: [CountGroup]) -> [GroupBar] {
        let items = self.items()
        return groups.map { group in
            let total = items
                .filter { $0.groupId == group.id }
                .reduce(0) { $0 + $1.value }
            return GroupBar(id: group.id, name: group.name, value: total, color: group.color)
        }
    }

    /// 指定項目のグループを変更する。
    func setGroup(index: Int, groupId: String?) {
        dataList.updateGroup(index: index, groupId: groupId)
        objectWillChange.send()
    }

    /// あるグループが削除されたとき、そのグループに属する項目を未所属に戻す。
    func detachItems(fromGroupId groupId: String) {
        for index in 0..<dataList.count() where dataList.groupId(index: index) == groupId {
            dataList.updateGroup(index: index, groupId: nil)
        }
        objectWillChange.send()
    }
}
