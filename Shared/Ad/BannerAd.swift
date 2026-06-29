//
//  BannerAd.swift
//  CounterGraph
//
//  Created by 上別縄祐也 on 2023/11/13.
//

import GoogleMobileAds
import SwiftUI

struct BannerView: UIViewControllerRepresentable {
    func makeUIViewController(context _: Context) -> UIViewController {
        let viewController = BannerAdViewController()
        return viewController
    }

    func updateUIViewController(_: UIViewController, context _: Context) {}
}

class BannerAdViewController: UIViewController, BannerViewDelegate {
    var bannerView: GoogleMobileAds.BannerView!
    let adUnitID = "ca-app-pub-3940256099942544/2934735716"//テスト

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadBanner()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { [weak self] _ in
            guard let self else { return }
            self.loadBanner()
        }
    }

    private func loadBanner() {
        bannerView = GoogleMobileAds.BannerView()
        bannerView.adUnitID = adUnitID

        bannerView.delegate = self
        bannerView.rootViewController = self

        let bannerWidth = view.frame.size.width
        bannerView.adSize = currentOrientationAnchoredAdaptiveBanner(width: bannerWidth)

        let request = Request()
        request.scene = view.window?.windowScene
        bannerView.load(request)

        setAdView(bannerView)
    }

    func setAdView(_ view: GoogleMobileAds.BannerView) {
        bannerView = view
        self.view.addSubview(bannerView)
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bannerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            bannerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            bannerView.topAnchor.constraint(equalTo: self.view.topAnchor),
            bannerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ])
    }
}
