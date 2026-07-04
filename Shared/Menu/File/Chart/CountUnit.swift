//
//  CountUnit.swift
//  CounterGraph
//
//  1カウントあたりの増減単位を管理する。
//  プリセット（1/10/100/1000）＋任意入力に対応し、fileId ごとに永続化する。
//

import SwiftUI

/// 1カウント単位を保持し、fileId ごとに UserDefaults へ保存する。
/// - プリセット: 1 / 10 / 100 / 1000（キーボードなしで素早く切替）
/// - カスタム: 金額や得点など桁の大きい任意値も入力できる
final class CountUnit: ObservableObject {
    /// チップとして並べるプリセット値。
    static let presets: [Int] = [1, 10, 100, 1000]

    /// 現在の増減単位。変更すると即座に保存する。
    @Published var value: Int {
        didSet { save() }
    }

    private let fileId: String
    private var storageKey: String { "CountUnit_file\(fileId)" }

    init(fileId: String) {
        self.fileId = fileId
        let saved = UserDefaults.standard.integer(forKey: "CountUnit_file\(fileId)")
        // 未保存(0)や不正値のときは 1 を既定にする。
        self.value = saved > 0 ? saved : 1
    }

    /// 現在の単位がプリセットに含まれず、カスタム入力である場合 true。
    var isCustom: Bool {
        !CountUnit.presets.contains(value)
    }

    private func save() {
        UserDefaults.standard.set(value, forKey: storageKey)
    }
}

/// 1カウント単位を選択するチップ列。プリセット＋カスタム入力（✎）。
struct CountUnitPicker: View {
    @ObservedObject var unit: CountUnit
    let tint: Color

    @State private var showCustomInput = false
    @State private var draft: Int = 1

    var body: some View {
        // ラベルは固定し、チップ列だけ横スクロールさせる。
        // カスタムで桁の大きい値を選んでもチップが折り返さず1行に収まる。
        HStack(spacing: 10) {
            Text(LocalizedStringKey("countWidth"))
                .font(.subheadline.weight(.medium))
                .foregroundColor(.secondary)
                .fixedSize()

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(CountUnit.presets, id: \.self) { preset in
                        chip(label: "\(preset)", selected: unit.value == preset) {
                            unit.value = preset
                        }
                    }

                    // カスタム入力チップ。常に✎アイコンを付け、プリセット（数字のみ）と
                    // 見た目で区別する。カスタム値が選択中ならアイコンの右に数値を併記する。
                    chip(label: unit.isCustom ? "\(unit.value)" : nil,
                         systemImage: "pencil",
                         selected: unit.isCustom) {
                        draft = unit.value
                        showCustomInput = true
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .alert(String(localized: "countWidth"), isPresented: $showCustomInput) {
            TextField("", value: $draft, format: .number)
            Button(String(localized: "Cancel"), role: .cancel) {}
            Button("OK") {
                if draft > 0 { unit.value = draft }
            }
        }
    }

    /// 単一チップ。systemImage と label は両方指定でき、指定した順（アイコン→数値）で横に並ぶ。
    @ViewBuilder
    private func chip(label: String? = nil,
                      systemImage: String? = nil,
                      selected: Bool,
                      action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.footnote.weight(.semibold))
                }
                if let label {
                    Text(label)
                }
            }
            .font(.subheadline.weight(.semibold))
            .foregroundColor(selected ? .white : tint)
            .frame(minWidth: 34, minHeight: 30)
            .padding(.horizontal, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(selected ? tint : tint.opacity(0.12))
            )
        }
        .buttonStyle(.plain)
    }
}
