//
//  MenuView.swift
//  CounterGraph
//
//  Created by 上別縄祐也 on 2023/11/11.
//

import SwiftUI

struct MenuView: View {
    @StateObject var menu = MenuViewModel()

    var body: some View {
        NavigationStack {
            List {
                ForEach(menu.files, id:\.self) { file in
                    NavigationLink(destination: FileView(fileId: file.id).environmentObject(menu)) {
                        HStack(spacing: 14) {
                            Image(systemName: "chart.bar.doc.horizontal.fill")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(Color.brand)
                                .frame(width: 40, height: 40)
                                .background(Color.brand.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            Text(file.title)
                                .font(.body.weight(.medium))
                            Spacer()
                        }
                        .padding(.vertical, 6)
                    }
                }
                .onMove(perform: menu.moveRow)
                .onDelete(perform: menu.removeRow)

                Button(action: {
                    menu.add()
                }, label: {
                    HStack(spacing: 14) {
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.brand)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        Text(String(localized: "Add"))
                            .font(.body.weight(.medium))
                            .foregroundColor(Color.brand)
                        Spacer()
                    }
                    .padding(.vertical, 6)
                })
            }
            .listStyle(.insetGrouped)
            .navigationTitle(String(localized: "Menu"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                        .tint(Color.brand)
                }
            }
            .tint(Color.brand)
        }.onChange(of: menu.refresh) { _ in
            menu.rebuildFiles()
        }
    }
}
