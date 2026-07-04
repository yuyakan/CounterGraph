//
//  ReviewDialogView.swift
//  CounterGraph
//
//  自作のレビュー依頼ダイアログ。ブランドカラーに合わせたデザイン。
//  「評価する」で App Store のレビューページへ、「あとで」で閉じる。
//

import SwiftUI

struct ReviewDialogView: View {
    /// 「評価する」を押したとき。
    let onRate: () -> Void
    /// 「あとで」を押したとき。
    let onDismiss: () -> Void

    @Environment(\.colorScheme) private var colorScheme
    @State private var appeared = false

    private var brandColor: Color { colorScheme == .dark ? .brandDark : .brandLight }

    var body: some View {
        ZStack {
            // 背景の暗幕。タップで閉じる。
            Color.black.opacity(appeared ? 0.4 : 0)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(spacing: 20) {
                // 星アイコン
                Image(systemName: "star.fill")
                    .font(.system(size: 44))
                    .foregroundColor(brandColor)
                    .padding(.top, 4)

                VStack(spacing: 8) {
                    Text(String(localized: "reviewTitle"))
                        .font(.title3.bold())
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    Text(String(localized: "reviewMessage"))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }

                VStack(spacing: 10) {
                    // 評価する（主ボタン）
                    Button(action: onRate) {
                        Text(String(localized: "reviewRate"))
                            .font(.body.weight(.semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .background(
                                RoundedRectangle(cornerRadius: 12).fill(brandColor)
                            )
                    }
                    // あとで（副ボタン）
                    Button(action: onDismiss) {
                        Text(String(localized: "reviewLater"))
                            .font(.body.weight(.medium))
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 11)
                    }
                }
            }
            .padding(24)
            .frame(maxWidth: 320)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.secondarySystemBackground))
            )
            .padding(.horizontal, 32)
            .scaleEffect(appeared ? 1 : 0.9)
            .opacity(appeared ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                appeared = true
            }
        }
    }
}
