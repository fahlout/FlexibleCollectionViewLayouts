//
//  FlexibleGridLayoutDataSource.swift
//  CollectionViewFlowTest
//
//  Created by Niklas Fahl on 9/7/18.
//  Copyright © 2018 Center for Advanced Public Safety. All rights reserved.
//

import UIKit

public protocol FlexibleGridLayoutDataSource: class {
    // Number of Columns in section
    func collectionView(_ collectionView:UICollectionView, numberOfColumnsInSection section:Int) -> Int
    
    // Item spans in row and column direction
    func collectionView(_ collectionView:UICollectionView, rowSpanForItemIndexPath indexPath:IndexPath) -> FlexibleGridSpan
    func collectionView(_ collectionView:UICollectionView, columnSpanForItemIndexPath indexPath:IndexPath) -> FlexibleGridSpan
}
