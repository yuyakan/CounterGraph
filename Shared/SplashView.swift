//
//  SplashView.swift
//  CounterGraph
//
//  起動時に表示するアプリ内スプラッシュ画面。
//  splash 画像を中央に表示し、一定時間後に onFinish を呼んでメニューへ遷移する。
//

import SwiftUI

struct SplashView: View {
    /// スプラッシュ表示が終わったときに呼ばれる。
    let onFinish: () -> Void

    /// ロゴのフェードイン/わずかな拡大用。
    @State private var appeared = false

    /// スプラッシュの表示時間（秒）。
    private let duration: TimeInterval = 1.5

    var body: some View {
        ZStack {
            // 画像が白背景のロゴのため、ダーク時も白で統一する。
            Color.white.ignoresSafeArea()

            Image("splash")
                .resizable()
                .scaledToFit()
                .frame(width: 220, height: 220)
                .opacity(appeared ? 1 : 0)
                .scaleEffect(appeared ? 1 : 0.92)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                appeared = true
            }
            // 表示時間経過後にメニューへ遷移する。
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                onFinish()
            }
        }
    }
}
