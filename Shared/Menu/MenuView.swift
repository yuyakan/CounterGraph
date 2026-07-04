//
//  MenuView.swift
//  CounterGraph
//
//  Created by 上別縄祐也 on 2023/11/11.
//

import SwiftUI

struct MenuView: View {
    @StateObject var menu = MenuViewModel()
    @StateObject private var setTemplates = SetTemplateStore()
    @State private var editMode: EditMode = .inactive
    /// Add カード押下時の「空 / テンプレから」選択ダイアログ。
    @State private var showAddChoice = false
    /// テンプレート選択シートの表示。
    @State private var showTemplatePicker = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                // 画面全体の背景（標準のグループ背景色を使わずニュートラルに）
                Color(.systemBackground).ignoresSafeArea()

                List {
                    // ヘッダー（編集トグルのみ・右寄せ）
                    HStack {
                        Spacer()
                        Button {
                            withAnimation { editMode = editMode.isEditing ? .inactive : .active }
                        } label: {
                            Text(editMode.isEditing ? String(localized: "Done") : String(localized: "Edit"))
                                .font(.body.weight(.semibold))
                                .foregroundColor(Color.brand)
                        }
                    }
                    .padding(.top, 8)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 12, trailing: 20))
                    .listRowBackground(Color.clear)

                    ForEach(menu.files, id:\.self) { file in
                        ZStack {
                            // カード全体をタップでグラフへ（NavigationLinkの矢印は隠す）
                            NavigationLink(destination: FileView(fileId: file.id).environmentObject(menu)) {
                                EmptyView()
                            }
                            .opacity(0)

                            fileCard(file)
                        }
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
                        .listRowBackground(Color.clear)
                        // 左スワイプで現在の項目セットをテンプレート化する。
                        .swipeActions(edge: .leading) {
                            Button {
                                setTemplates.saveTemplate(fromFileId: file.id)
                            } label: {
                                Label(String(localized: "saveSetAsTemplate"), systemImage: "square.and.arrow.down")
                            }
                            .tint(Color.brand)
                        }
                    }
                    .onMove(perform: menu.moveRow)
                    .onDelete(perform: menu.removeRow)

                    // 新規追加カード。テンプレートがあれば「空 / テンプレから」を選ばせる。
                    Button(action: {
                        if setTemplates.templates.isEmpty {
                            menu.add()
                        } else {
                            showAddChoice = true
                        }
                    }, label: {
                        addCard
                    })
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
                    .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .environment(\.editMode, $editMode)
            }
            .navigationBarHidden(true)
            .tint(Color.brand)
        }.onChange(of: menu.refresh) { _ in
            menu.rebuildFiles()
        }
        // Add カード押下時の作成方法の選択。
        .confirmationDialog(String(localized: "Add"), isPresented: $showAddChoice, titleVisibility: .visible) {
            Button(String(localized: "emptyNew")) { menu.add() }
            Button(String(localized: "newFromTemplate")) { showTemplatePicker = true }
            Button(String(localized: "Cancel"), role: .cancel) {}
        }
        // テンプレート選択シート。
        .sheet(isPresented: $showTemplatePicker) {
            TemplatePickerSheet(store: setTemplates) { template in
                menu.addFromTemplate(template, using: setTemplates)
            }
        }
    }

    /// ファイル1件分のカード。
    private func fileCard(_ file: File) -> some View {
        HStack(spacing: 14) {
            Image(systemName: "chart.bar.doc.horizontal.fill")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Color.brand)
                .frame(width: 44, height: 44)
                .background(Color.brand.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            Text(file.title)
                .font(.body.weight(.medium))
                .foregroundColor(.primary)
            Spacer()
            if !editMode.isEditing {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary.opacity(0.5))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }

    /// 新規追加カード。
    private var addCard: some View {
        HStack(spacing: 14) {
            Image(systemName: "plus")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(Color.brand)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            Text(String(localized: "Add"))
                .font(.body.weight(.semibold))
                .foregroundColor(Color.brand)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.brand.opacity(0.4), style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
        )
    }
}

/// 保存済みの項目セットテンプレートから1つ選ぶシート。
private struct TemplatePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store: SetTemplateStore
    /// 選択されたテンプレートを親へ渡す。
    let onSelect: (SetTemplate) -> Void

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.templates) { template in
                    Button {
                        onSelect(template)
                        dismiss()
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(template.title)
                                .font(.body.weight(.medium))
                                .foregroundColor(.primary)
                            // 含まれる項目名をプレビュー表示。
                            Text(template.itemNames.joined(separator: "・"))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            store.remove(template)
                        } label: {
                            Label(String(localized: "deleteTemplate"), systemImage: "trash")
                        }
                    }
                }
            }
            .navigationTitle(String(localized: "chooseTemplate"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancel")) { dismiss() }
                }
            }
        }
    }
}
