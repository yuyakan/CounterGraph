//
//  MenuView.swift
//  CounterGraph
//
//  Created by 上別縄祐也 on 2023/11/11.
//

import SwiftUI

struct MenuView: View {
    @StateObject var menu = MenuViewModel()
    // 広告は1インスタンスをアプリ全体で共有し、先読みしておく。
    @StateObject private var interstitial = Interstitial()
    @StateObject private var adCounter = AdCounter()
    @StateObject private var reviewManager = ReviewManager()
    @State private var editMode: EditMode = .inactive

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
                            NavigationLink(destination: FileView(fileId: file.id)
                                .environmentObject(menu)
                                .environmentObject(interstitial)
                                .environmentObject(adCounter)) {
                                EmptyView()
                            }
                            .opacity(0)

                            fileCard(file)
                        }
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
                        .listRowBackground(Color.clear)
                    }
                    .onMove(perform: menu.moveRow)
                    .onDelete(perform: menu.removeRow)

                    // 新規追加カード
                    Button(action: {
                        menu.add()
                        adCounter.increment(by: 3)   // 追加は3回分
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
                .onAppear {
                    // メニュー画面が前面に来るたび（起動時・詳細画面から戻った時）に
                    // レビュー要求の機会をカウントする。
                    // 詳細画面遷移時にすぐ表示できるよう広告も先読みしておく。
                    interstitial.loadInterstitial()
                    Task { @MainActor in
                        try? await Task.sleep(nanoseconds: 500_000_000)
                        reviewManager.recordOpportunityAndRequestReviewIfNeeded()
                    }
                }
            }
            .navigationBarHidden(true)
            .tint(Color.brand)
        }.onChange(of: menu.refresh) { _ in
            menu.rebuildFiles()
        }
    }

    /// ファイル1件分のカード。編集モードでは複製ボタン、通常時は遷移矢印を表示する。
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
            if editMode.isEditing {
                // 編集モード中はカードを複製できる。
                Button {
                    menu.duplicate(file: file)
                    adCounter.increment(by: 3)   // 複製は3回分
                } label: {
                    Image(systemName: "plus.square.on.square")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color.brand)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(String(localized: "Duplicate"))
            } else {
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
