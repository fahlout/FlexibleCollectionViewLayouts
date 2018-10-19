//
//  DemoMenuTableViewController.swift
//  CollectionViewFlowTest
//
//  Created by Niklas Fahl on 9/5/18.
//  Copyright © 2018 fahlout. All rights reserved.
//

import UIKit

enum DemoMenu: String {
    case defaultColumnDemo = "Default Column Grid Demo"
    case advancedColumnDemo = "Advanced Column Demo"
    case advancedGridDemo = "Advanced Grid Demo"
}

class DemoMenuTableViewController: UITableViewController {

    let reuseIdentifier = "MenuItemCell"
    let menuItems: [Int: [DemoMenu]] = [0: [.defaultColumnDemo, .advancedColumnDemo], 1: [.advancedGridDemo]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return menuItems.keys.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems[section]?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Flexible Column Layout Demos" : "Flexible Grid Layout Demos"
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        cell.textLabel?.text = menuItems[indexPath.section]![indexPath.row].rawValue
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch menuItems[indexPath.section]![indexPath.row] {
        case .defaultColumnDemo:
            let demoVC = FlexibleColumnLayoutDefaultGridCollectionViewController(collectionViewLayout: FlexibleColumnLayout())
            navigationController?.pushViewController(demoVC, animated: true)
        case .advancedColumnDemo:
            let demoVC = FlexibleColumnLayoutAdvancedDemoCollectionViewController(collectionViewLayout: FlexibleColumnLayout())
            navigationController?.pushViewController(demoVC, animated: true)
        case .advancedGridDemo:
            let demoVC = FlexibleGridLayoutAdvancedGridCollectionViewController(collectionViewLayout: FlexibleGridLayout())
            navigationController?.pushViewController(demoVC, animated: true)
        }
    }
}
