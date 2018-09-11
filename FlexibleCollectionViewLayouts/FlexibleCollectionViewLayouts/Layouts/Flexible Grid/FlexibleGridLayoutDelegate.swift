//
//  FlexibleGridLayoutDelegate.swift
//  CollectionViewFlowTest
//
//  Created by Niklas Fahl on 9/7/18.
//  Copyright © 2018 fahlout. All rights reserved.
//

import UIKit

public protocol FlexibleGridLayoutDelegate: class {
    // Header and Footer sizes
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize
    
    // Section background
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, shouldRenderSectionBackgroundForSection section: Int) -> Bool
    
    // Row dimensions
    func collectionView(_ collectionView:UICollectionView, layout collectionViewLayout: UICollectionViewLayout, heightForRow row: Int, inSection section: Int) -> CGFloat
    
    // Spacing and insets
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, lineSpacingForSection section: Int) -> CGFloat
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, interitemSpacingForSection section: Int) -> CGFloat
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, interSectionSpacingBetweenSection firstSection: Int, andSection secondSection: Int) -> CGFloat
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetsForSection section: Int) -> UIEdgeInsets
}

extension FlexibleGridLayoutDelegate {
    // Default delegate values
    
    // Header and Footer sizes
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .zero
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return .zero
    }
    
    // Section background
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, shouldRenderSectionBackgroundForSection section: Int) -> Bool {
        return false
    }
    
    // Row and Column dimensions
    func collectionView(_ collectionView:UICollectionView, layout collectionViewLayout: UICollectionViewLayout, heightForRow row: Int, inSection section: Int) -> CGFloat {
        return FlexibleGridLayoutEqualRowHeightToColumnWidth
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, columnSizeForColumn column: Int, inSection section: Int) -> FlexibleColumnWidth {
        return .equalRatio
    }
    
    // Spacing and insets
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, lineSpacingForSection section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, interitemSpacingForSection section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, interSectionSpacingBetweenSection firstSection: Int, andSection secondSection: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetsForSection section: Int) -> UIEdgeInsets {
        return .zero
    }
}
