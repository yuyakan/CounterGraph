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
        NavigationView {
            List {
                ForEach(menu.files, id:\.self) { file in
                    NavigationLink(destination: FileView(fileId: file.id).environmentObject(menu), label: {
                        Text(file.title)
                            .frame(height: 42)
                    })
                }
                .onMove(perform: menu.moveRow)
                .onDelete(perform: menu.removeRow)
                Button(action: {
                    menu.add()
                }, label: {
                    Image(systemName: "plus.square.on.square")
                        .font(.system(size: 20))
                        .frame(height: 42)
                        .foregroundColor(Color.blue)
                })
        
                Spacer(minLength: 300)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(String(localized: "Menu"))
            .navigationBarItems(trailing: EditButton())
        }.onChange(of: menu.refresh) { _ in
            menu.rebuildFiles()
        }
    }
}
