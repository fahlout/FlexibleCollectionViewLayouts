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
//        menuNavigationController.navigationBar.largeTitleTextAttributes =
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = menuNavigationController
        window?.makeKeyAndVisible()
        
        let cell = TextCell()
        cell.label.text = "This is a autoresizing test"
//        cell.autosize(maxWidth: 500)
        let newSize = cell.sizeThatFits(CGSize(width: 500, height: CGFloat.greatestFiniteMagnitude))
//        print(newSize)
//        print(cell.frame)
        
        return true
    }
}


extension UIView {
    
    func autosize(maxWidth: CGFloat) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        let dummyContainerView = UIView(frame: CGRect(x: 0, y: 0, width: maxWidth, height: 1000000))
        dummyContainerView.addSubview(self)
        dummyContainerView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        dummyContainerView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        dummyContainerView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true

        let size = sizeThatFits(CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude))
        print(size)
//        setNeedsLayout()
//        layoutIfNeeded()
        
        removeFromSuperview()
        
        frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: frame.height)
        
        translatesAutoresizingMaskIntoConstraints = true
    }
}
