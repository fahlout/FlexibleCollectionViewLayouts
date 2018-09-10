//
//  FlexibleColumnLayoutAdvancedDemoCollectionViewController.swift
//  CollectionViewFlowTest
//
//  Created by Niklas Fahl on 9/5/18.
//  Copyright © 2018 Center for Advanced Public Safety. All rights reserved.
//

import UIKit

class FlexibleColumnLayoutAdvancedDemoCollectionViewController: UICollectionViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = UIColor.white
        navigationItem.largeTitleDisplayMode = .never
        
        // Register cells and supplementary views
        collectionView?.register(TextCell.self, forCellWithReuseIdentifier: "cell")
        collectionView?.register(UINib(nibName: String(describing: TitleCollectionReusableView.self), bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: String(describing: TitleCollectionReusableView.self))
        collectionView?.register(UINib(nibName: String(describing: TitleCollectionReusableView.self), bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: String(describing: TitleCollectionReusableView.self))
        
        // Set Flexible Column Layout Delegate and Data Source
        if let layout = collectionView?.collectionViewLayout as? FlexibleColumnLayout {
            layout.delegate = self
            layout.dataSource = self
        }
    }
    
    // In order to have the layout work when switching size classes on device
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { (_) in
            self.collectionViewLayout.invalidateLayout()
            self.collectionView?.reloadData()
        }, completion: nil)
    }
}

extension FlexibleColumnLayoutAdvancedDemoCollectionViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 1:
            return 7
        case 2:
            return 3
        default:
            return 4
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! TextCell
        let hue = CGFloat(((indexPath.item + 1) * 5) +  ((indexPath.section + 1) * 255 / numberOfSections(in: collectionView))) / 255
        cell.backgroundColor = UIColor(hue: hue, saturation: 1, brightness: 1, alpha: 1)
        cell.label.text = "Item: (\(indexPath.section), \(indexPath.item))"
        cell.layer.cornerRadius = 0
        if indexPath.section == 0 {
            cell.layer.cornerRadius = cell.frame.width / 2
        } else if indexPath.section == 2 {
            cell.backgroundColor = UIColor(white: 0.8, alpha: 100)
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if indexPath.section == 2 {
            guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: String(describing: TitleCollectionReusableView.self), for: indexPath) as? TitleCollectionReusableView else {
                fatalError()
            }
            view.titleLabel.text = "\(kind == UICollectionElementKindSectionHeader ? "Header" : "Footer") \(indexPath.section)"
            view.titleLabel.textColor = kind == UICollectionElementKindSectionHeader ? .white : .black
            view.titleLabel.font = kind == UICollectionElementKindSectionHeader ? UIFont.systemFont(ofSize: 20, weight: .bold) : UIFont.systemFont(ofSize: 14)
            view.titleLabel.textAlignment = kind == UICollectionElementKindSectionHeader ? .left : .center
            view.backgroundColor = kind == UICollectionElementKindSectionHeader ? .darkGray : .lightGray
            return view
        } else {
            return UICollectionReusableView()
        }
    }
}

// MARK: - Flexible Column Layout Data Source
extension FlexibleColumnLayoutAdvancedDemoCollectionViewController: FlexibleColumnLayoutDataSource {
    func collectionView(_ collectionView:UICollectionView, numberOfColumnsInSection section:Int) -> Int {
        switch section {
        case 1:
            return 3
        case 2:
            return 2
        default:
            return 4
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, columnForItemAtIndexPath indexPath: IndexPath, withNumberOfColumns numberOfColumns: Int) -> Int {
        if indexPath.section == 2 {
            if indexPath.item < 2 {
                return 0
            }
            return 1
        }
        return indexPath.item % numberOfColumns
    }
}

// MARK: - Flexible Column Layout Delegate
extension FlexibleColumnLayoutAdvancedDemoCollectionViewController : FlexibleColumnLayoutDelegate {
    // Size for header and footer
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 2 {
            return CGSize(width: collectionView.frame.size.width, height: 65)
        }
        return CGSize(width: collectionView.frame.size.width, height: 0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if section == 2 {
            return CGSize(width: collectionView.frame.size.width, height: 30)
        }
        return CGSize(width: collectionView.frame.size.width, height: 0)
    }
    
    // Height for each item
    func collectionView(_ collectionView:UICollectionView, layout collectionViewLayout: UICollectionViewLayout, heightForItemAtIndexPath indexPath:IndexPath) -> CGFloat {
        if indexPath == IndexPath(item: 4, section: 1) {
            return 60
        } else if indexPath.section == 2 {
            if indexPath.item == 0 {
                return 350
            } else if indexPath.item == 1 {
                return 100
            }
            return 700
        }
        return FlexibleColumnLayoutEqualHeightToColumnWidth
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, heightMultipleForItemAtIndexPath indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
            if indexPath.item % 3 == 0 || indexPath.item % 3 == 2 {
                return 1.2
            }
        }
        return 1
    }
    
    // Column size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, columnSizeForColumn column: Int, inSection section: Int) -> FlexibleColumnWidth {
        if section == 1 {
            if column == 0 {
                return .equalTo(100)
            } else if column == 1 {
                return .ratio(0.5)
            }
        } else if section == 2 {
            if column == 0 {
                return .equalTo(200)
            }
        }
        return .equalRatio
    }
    
    // Spacing and insets
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, lineSpacingForSection section: Int) -> CGFloat {
        if section == 2 {
            return 1
        }
        return 10
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, interitemSpacingForSection section: Int) -> CGFloat {
        if section == 2 {
            return 1
        }
        return 10
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetsForSection section: Int) -> UIEdgeInsets {
        if section == 0 {
            return UIEdgeInsets(top: 40, left: 40, bottom: 40, right: 40)
        } else if section == collectionView.numberOfSections - 1 {
            return .zero
        }
        return UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16)
    }
}
