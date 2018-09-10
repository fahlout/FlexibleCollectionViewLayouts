//
//  AppDelegate.swift
//  FlexibleCollectionViewLayouts
//
//  Created by Niklas Fahl on 9/10/18.
//  Copyright © 2018 fahlout. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let menuVC = DemoMenuTableViewController(style: .grouped)
        menuVC.tableView?.alwaysBounceVertical = true
        menuVC.title = "Layout Demos"
        
        let menuNavigationController = UINavigationController(rootViewController: menuVC)
        menuNavigationController.navigationBar.prefersLargeTitles = true
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = menuNavigationController
        window?.makeKeyAndVisible()
        
        return true
    }
}
