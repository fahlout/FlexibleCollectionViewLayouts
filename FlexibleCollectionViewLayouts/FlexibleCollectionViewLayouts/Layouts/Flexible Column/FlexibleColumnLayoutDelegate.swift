//
//  FlexibleColumnLayoutDelegate.swift
//  CollectionViewFlowTest
//
//  Created by Niklas Fahl on 9/5/18.
//  Copyright © 2018 fahlout. All rights reserved.
//

import UIKit

public protocol FlexibleColumnLayoutDelegate: UICollectionViewDelegate {
    // Size for header and footer
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize
    
    // Section background
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, shouldRenderSectionBackgroundForSection section: Int) -> Bool
    
    // Height for each item
    func collectionView(_ collectionView:UICollectionView, layout collectionViewLayout: UICollectionViewLayout, heightForItemAtIndexPath indexPath: IndexPath) -> CGFloat
    func collectionView(_ collectionView:UICollectionView, layout collectionViewLayout: UICollectionViewLayout, heightMultipleForItemAtIndexPath indexPath: IndexPath) -> CGFloat
    
    // Column size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, columnSizeForColumn column: Int, inSection section: Int) -> FlexibleColumnWidth
    
    // Spacing and insets
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, lineSpacingForSection section: Int) -> CGFloat
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, interitemSpacingForSection section: Int) -> CGFloat
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, interSectionSpacingBetweenSection firstSection: Int, andSection secondSection: Int) -> CGFloat
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetsForSection section: Int) -> UIEdgeInsets
}

extension FlexibleColumnLayoutDelegate {
    // Default delegate values
    
    // Size for header and footer
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
    
    // Height for each item
    func collectionView(_ collectionView:UICollectionView, layout collectionViewLayout: UICollectionViewLayout, heightForItemAtIndexPath indexPath: IndexPath) -> CGFloat {
        return FlexibleColumnLayoutEqualHeightToColumnWidth
    }
    func collectionView(_ collectionView:UICollectionView, layout collectionViewLayout: UICollectionViewLayout, heightMultipleForItemAtIndexPath indexPath: IndexPath) -> CGFloat {
        return 1
    }
    
    // Column size
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
