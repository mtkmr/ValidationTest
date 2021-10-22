//
//  AppDelegate.swift
//  ValidationTest
//
//  Created by Masato Takamura on 2021/10/22.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let vc = UIStoryboard(name: "ValidationTest", bundle: nil).instantiateInitialViewController() as! ValidationTestViewController
        let nav = UINavigationController(rootViewController: vc)
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = nav
        window.makeKeyAndVisible()
        self.window = window
        return true
    }
}

