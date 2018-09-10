//
//  FlexibleColumnLayoutDataSource.swift
//  CollectionViewFlowTest
//
//  Created by Niklas Fahl on 9/5/18.
//  Copyright © 2018 fahlout. All rights reserved.
//

import UIKit

@objc public protocol FlexibleColumnLayoutDataSource: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfColumnsInSection section: Int) -> Int
    @objc optional func collectionView(_ collectionView: UICollectionView, columnForItemAtIndexPath indexPath: IndexPath, withNumberOfColumns numberOfColumns: Int) -> Int
}
