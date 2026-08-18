//
//  ItemSheets.swift
//  CounterGraph
//
//  棒グラフ・円グラフの編集モードで共有する項目編集シート。
//  特定の ViewModel に依存せず、入力値の受け渡しはクロージャで行う。
//

import SwiftUI

/// 編集対象の項目（sheet(item:) 用の Identifiable ラッパ）。
struct EditTarget: Identifiable { let id: Int }

/// 既存項目の名前・値を編集するシート。
struct ItemEditSheet: View {
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
/// よく使う名前（テンプレート）をチップで呼び出せ、任意でこの名前をテンプレ登録できる。
/// 入力値の保持と追加処理は呼び出し側にバインディング／クロージャで委ねる。
struct AddItemSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var name: String
    @Binding var value: Int
    @ObservedObject var templates: NameTemplateStore
    let buttonColor: Color
    let onAdd: () -> Void

    /// Add 時にこの名前をテンプレートへ登録するか。既定でON。
    @State private var saveAsTemplate = true

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(String(localized: "Jack"), text: $name)
                    TextField(String(localized: "Value"), value: $value, format: .number)
                        .keyboardType(.numberPad)
                    Toggle(String(localized: "saveAsTemplate"), isOn: $saveAsTemplate)
                        .tint(buttonColor)
                }

                // 登録済みテンプレート（よく使う名前）をワンタップで名前欄に入れる。
                if !templates.names.isEmpty {
                    Section(String(localized: "templates")) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(templates.names, id: \.self) { templateName in
                                    Button {
                                        name = templateName
                                    } label: {
                                        Text(templateName)
                                            .font(.subheadline.weight(.medium))
                                            .foregroundColor(buttonColor)
                                            .lineLimit(1)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 7)
                                            .background(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(buttonColor.opacity(0.12))
                                            )
                                    }
                                    .buttonStyle(.plain)
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            templates.remove(templateName)
                                        } label: {
                                            Label(String(localized: "deleteTemplate"), systemImage: "trash")
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 2)
                        }
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    }
                }
            }
            .navigationTitle(String(localized: "Add"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Add")) {
                        if saveAsTemplate {
                            templates.add(name)
                        }
                        onAdd()
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}
