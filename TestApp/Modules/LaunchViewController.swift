//
//  LaunchViewController.swift
//  TestApp
//
//  Created by Никита Лужбин on 03.12.2023.
//

import Foundation
import UIKit
import Lottie
import PureLayout

final class LaunchViewController: UIViewController {

    private let lottieView = LottieAnimationView()

    override func viewDidLoad() {
        view.backgroundColor = .white

        lottieView.animation = .named("plane_animation")
        lottieView.animationSpeed = 2
        lottieView.play(
            fromFrame: 45,
            toFrame: 180,
            loopMode: .playOnce) { completed in
                let rootController = RootViewController()
                let navigationController = UINavigationController(rootViewController: rootController)
                navigationController.navigationBar.tintColor = .black

                UIApplication.shared.keyWindow?.rootViewController = navigationController
            }

        view.addSubview(lottieView)

        lottieView.autoCenterInSuperview()
    }
}
