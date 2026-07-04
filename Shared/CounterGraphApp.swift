//
//  CounterGraphApp.swift
//  Shared
//
//  Created by 上別縄祐也 on 2022/02/19.
//

import SwiftUI
import UIKit
import GoogleMobileAds


// AppDelegateクラスを定義する
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Mobile Ads SDKを初期化する
        MobileAds.shared.start(completionHandler: nil)
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
