//
//  ColumnFlowLayout.swift
//  CollectionViewFlowTest
//
//  Created by Niklas Fahl on 8/29/18.
//  Copyright © 2018 fahlout. All rights reserved.
//

import UIKit

public class FlexibleColumnLayout: UICollectionViewLayout {
    
    public weak var delegate: FlexibleColumnLayoutDelegate?
    public weak var dataSource: FlexibleColumnLayoutDataSource?
    
    private(set) var itemCache = [IndexPath: UICollectionViewLayoutAttributes]()
    private(set) var sectionBackgroundCache = [UICollectionViewLayoutAttributes]()
    private(set) var headerCache = [UICollectionViewLayoutAttributes]()
    private(set) var footerCache = [UICollectionViewLayoutAttributes]()
    private(set) var cachedContentSize: CGSize = .zero
    
    override open var collectionViewContentSize: CGSize {
        return self.cachedContentSize
    }
    
    public override func prepare() {
        guard let collectionView = collectionView, let delegate = delegate, let dataSource = dataSource else { return }
        
        // Clear cache
        itemCache.removeAll()
        sectionBackgroundCache.removeAll()
        headerCache.removeAll()
        footerCache.removeAll()
        
        // Layout properties
        let numberOfSections = collectionView.numberOfSections
        var maxY: CGFloat = 0
        let contentWidth = collectionView.frame.width - (collectionView.contentInset.left + collectionView.contentInset.right)
        
        for section in 0 ..< numberOfSections {
            // Setup initial max y for section
            let sectionStartY = maxY
            let sectionInsets = delegate.collectionView(collectionView, layout: self, insetsForSection: section)
            maxY = maxY + sectionInsets.top
            
            // Section properties
            let numberOfColumns = dataSource.collectionView(collectionView, numberOfColumnsInSection: section)
            let numberOfItems = collectionView.numberOfItems(inSection: section)
            let lineSpacing = delegate.collectionView(collectionView, layout: self, lineSpacingForSection: section)
            let interitemSpacing = delegate.collectionView(collectionView, layout: self, interitemSpacingForSection: section)
            let sectionInteritemSpacings = CGFloat(numberOfColumns - 1) * interitemSpacing
            let sectionLeftRightInset = sectionInsets.left + sectionInsets.right
            
            // Header Attributes
            let headerSize = delegate.collectionView(collectionView, layout: self, referenceSizeForHeaderInSection: section)
            if headerSize.height > 0.0 {
                let headerAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, with: IndexPath(item: 0, section: section))
                headerAttributes.frame = CGRect(x: sectionInsets.left, y: maxY, width: contentWidth - sectionLeftRightInset, height: headerSize.height)
                headerCache.append(headerAttributes)
            }
            
            // Update max y based on header
            maxY = maxY + headerSize.height
            var yOffset = [CGFloat](repeating: maxY, count: numberOfColumns)
            
            let usableContentWidth = contentWidth - sectionInteritemSpacings - sectionLeftRightInset
            let layoutColumnWidths: [FlexibleColumnWidth] = (0..<numberOfColumns).map { return delegate.collectionView(collectionView, layout: self, columnSizeForColumn: $0, inSection: section) }
            
            // Check for exact column widths and validate them
            let exactWidthColumnWidths = layoutColumnWidths.filter { (width) -> Bool in
                switch width {
                case .equalTo(_):
                    return true
                default:
                    return false
                }
                }.map { (width) -> CGFloat in
                    switch width {
                    case let .equalTo(value):
                        return value
                    default:
                        return 0
                    }
            }
            let totalExactWidthColumnWidths = exactWidthColumnWidths.reduce(0, +)
            if totalExactWidthColumnWidths > usableContentWidth { fatalError("Total exact column widths may not exceed the usable content width, which is the collection view width minus any horizontal insets.") }
            
            // Check if ratios add up to less than 100%
            let columnWidthRatios = layoutColumnWidths.filter { (width) -> Bool in
                switch width {
                case .ratio(_):
                    return true
                default:
                    return false
                }
                }.map { (width) -> CGFloat in
                    switch width {
                    case let .ratio(value):
                        return value
                    default:
                        return 0
                    }
            }
            let unequalColumnWidthRatios = columnWidthRatios.reduce(0, +)
            let effectiveUsableWidth = usableContentWidth - totalExactWidthColumnWidths
            let effectiveUsableRatio = effectiveUsableWidth / usableContentWidth
            if unequalColumnWidthRatios > effectiveUsableRatio { fatalError("Total column ratios may not exceed \(effectiveUsableRatio).") }
            
            // Calculate width for each column
            let unequalColumnCount = numberOfColumns - exactWidthColumnWidths.count - columnWidthRatios.count
            let equalColumnUsableContentWidth = effectiveUsableWidth - (unequalColumnWidthRatios * usableContentWidth)
            let equalColumnWidth = equalColumnUsableContentWidth / CGFloat(unequalColumnCount)
            let columnWidths = layoutColumnWidths.map { (width) -> CGFloat in
                switch width {
                case .equalRatio:
                    return equalColumnWidth
                case let .ratio(value):
                    return usableContentWidth * value
                case let .equalTo(value):
                    return value
                }
            }
            
            // Item Attributes
            for item in 0 ..< numberOfItems {
                let indexPath = IndexPath(item: item, section: section)
                let column = dataSource.collectionView?(collectionView, columnForItemAtIndexPath: indexPath, withNumberOfColumns: numberOfColumns) ?? item % numberOfColumns
                let columnWidth = columnWidths[column]
                
                // Calculate cell frame
                let heightMultiple = delegate.collectionView(collectionView, layout: self, heightMultipleForItemAtIndexPath: indexPath)
                let itemHeight = delegate.collectionView(collectionView, layout: self, heightForItemAtIndexPath: indexPath)
                let heightParameter = itemHeight == FlexibleColumnLayoutEqualHeightToColumnWidth ? columnWidth : itemHeight
                let height = heightMultiple * heightParameter + (heightMultiple - 1.0) * lineSpacing
                
                // Calculate item x offset based on leading column widths
                let columnOffset = (0..<column).reduce(0, {$0 + columnWidths[$1]})
                let xOffset = columnOffset + CGFloat(column) * interitemSpacing + sectionInsets.left
                let frame = CGRect(x: xOffset, y: yOffset[column], width: columnWidth, height: height)
                
                // Create layout attribute for item and add to cache
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = frame
                itemCache[indexPath] = attributes
                
                // Calculate line spacing
                let isLastRow = (item - numberOfItems + numberOfColumns) >= 0
                let lineSpacingForItem = isLastRow ? 0 : lineSpacing
                
                // Update max y offset based on line spacing and item height
                yOffset[column] = yOffset[column] + height + lineSpacingForItem
                maxY = max(maxY, yOffset[column])
            }
            
            // Footer Attributes
            let footerSize = delegate.collectionView(collectionView, layout: self, referenceSizeForFooterInSection: section)
            if footerSize.height > 0.0 {
                let footerAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, with: IndexPath(item: 0, section: section))
                footerAttributes.frame = CGRect(x: sectionInsets.left, y: maxY, width: contentWidth - sectionLeftRightInset, height: footerSize.height)
                footerCache.append(footerAttributes)
            }
            
            // Update max y for next section
            maxY = maxY + footerSize.height + sectionInsets.bottom
            cachedContentSize = CGSize(width: contentWidth, height: maxY)
            
            // Section Background Attributes
            if delegate.collectionView(collectionView, layout: self, shouldRenderSectionBackgroundForSection: section) {
                let sectionBackgroundAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionBackground, with: IndexPath(item: 0, section: section))
                sectionBackgroundAttributes.frame = CGRect(x: 0, y: sectionStartY, width: contentWidth, height: maxY - sectionStartY)
                sectionBackgroundAttributes.zIndex = -1
                sectionBackgroundCache.append(sectionBackgroundAttributes)
            }
        }
    }
    
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        // Loop through the cache and look for items in the rect
        let itemLayoutAttributes = itemCache.compactMap { return $0.value }
        return (itemLayoutAttributes + headerCache + footerCache + sectionBackgroundCache).filter { (attributes) -> Bool in
            return attributes.frame.intersects(rect)
        }
    }
    
    public override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if elementKind == UICollectionElementKindSectionHeader {
            return headerCache[indexPath.section]
        } else if elementKind == UICollectionElementKindSectionFooter {
            return footerCache[indexPath.section]
        } else if elementKind == UICollectionElementKindSectionBackground {
            return sectionBackgroundCache[indexPath.section]
        }
        return nil
    }
    
    public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return itemCache[indexPath]
    }
}
