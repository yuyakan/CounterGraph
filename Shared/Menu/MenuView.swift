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
        var titleList = menu.titleList()
        NavigationView {
            List {
                ForEach(0..<titleList.count, id:\.self) { index in
                    NavigationLink(destination: FileView(fileId: index).environmentObject(menu), label: {
                        Text(titleList[index])
                    })
                }
                Spacer(minLength: 300)
            }
            .navigationBarHidden(true)
        }.onAppear(perform: {
            titleList = menu.titleList()
        })
    }
}
