//
//  CounterGraphApp.swift
//  Shared
//
//  Created by 上別縄祐也 on 2022/02/19.
//

import SwiftUI
import UIKit


// AppDelegateクラスを定義する
class AppDelegate: NSObject, UIApplicationDelegate {
    /// 広告の同意フロー（UMP + ATT）を管理する。
    /// 起動中に解放されないよう AppDelegate が強参照で保持する。
    private let consentManager = ConsentManager()

    func application(_ application: UIApplication,didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // 同意を取得してから Mobile Ads SDK を初期化する。
        // （UMP の同意 → ATT 要求 → SDK 初期化 の順は ConsentManager 内部で実施）
        consentManager.gatherConsent()
        return true
    }
}

@main
struct CounterGraphApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    /// スプラッシュ表示中かどうか。表示が終わるとメニューへフェード遷移する。
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                MenuView()

                if showSplash {
                    SplashView {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            showSplash = false
                        }
                    }
                    .transition(.opacity)
                    .zIndex(1)
                }
            }
        }
    }
}
