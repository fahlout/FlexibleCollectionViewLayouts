//
//  FlexibleGridLayout.swift
//
//  Created by Niklas Fahl on 8/29/18.
//  Copyright © 2018 Center for Advanced Public Safety. All rights reserved.
//

import UIKit

public let FlexibleGridLayoutEqualRowHeightToColumnWidth: CGFloat = -1.0

public enum FlexibleColumnWidth {
    case equalRatio
    case ratio(CGFloat)
    case equalTo(CGFloat)
}

public enum FlexibleGridSpan {
    case fromTo(Int, Int)
    case at(Int)
}

public class FlexibleGridLayout: UICollectionViewLayout {
    //1. Pinterest Layout Delegate
    public weak var delegate: FlexibleGridLayoutDelegate?
    public weak var dataSource: FlexibleGridLayoutDataSource?

    // Array to keep a cache of attributes
    public var itemCache = [IndexPath: UICollectionViewLayoutAttributes]()
    fileprivate var headerCache = [UICollectionViewLayoutAttributes]()
    fileprivate var footerCache = [UICollectionViewLayoutAttributes]()

    // Content height and size
    fileprivate var contentHeight: CGFloat = 0

    fileprivate var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }

    public override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }

    public override func prepare() {
        super.prepare()

        guard let collectionView = collectionView, let delegate = delegate, let dataSource = dataSource else { return }

        // Reset cache
        itemCache = [IndexPath: UICollectionViewLayoutAttributes]()
        headerCache = [UICollectionViewLayoutAttributes]()
        footerCache = [UICollectionViewLayoutAttributes]()

        let numberOfSections = collectionView.numberOfSections
        var maxY: CGFloat = 0

        // 3. Iterates through the list of items in the first section
        for section in 0 ..< numberOfSections {
            // Setup initial max y for section
            let sectionInsets = delegate.collectionView(collectionView, layout: self, insetsForSection: section)
            maxY = maxY + sectionInsets.top
            
            // Section properties
            let numberOfColumns = dataSource.collectionView(collectionView, numberOfColumnsInSection: section)
            let numberOfItems = collectionView.numberOfItems(inSection: section)
            let lineSpacing = delegate.collectionView(collectionView, layout: self, lineSpacingForSection: section)
            let interitemSpacing = delegate.collectionView(collectionView, layout: self, interitemSpacingForSection: section)
            let sectionInteritemSpacings = CGFloat(numberOfColumns - 1) * interitemSpacing
            let sectionLeftRightInset = sectionInsets.left + sectionInsets.right
            
            // Header
            let headerSize = delegate.collectionView(collectionView, layout: self, referenceSizeForHeaderInSection: section)
            if headerSize.height > 0.0 {
                let headerAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, with: IndexPath(item: 0, section: section))
                headerAttributes.frame = CGRect(x: 0, y: maxY, width: contentWidth, height: headerSize.height)
                headerCache.append(headerAttributes)
            }

            maxY = maxY + headerSize.height
            var yOffset = [CGFloat](repeating: maxY, count: numberOfColumns)
            let columnWidth = contentWidth / CGFloat(numberOfColumns)

            for item in 0 ..< numberOfItems {

                let indexPath = IndexPath(item: item, section: section)
                let columnSpan = dataSource.collectionView(collectionView, columnSpanForItemIndexPath: indexPath)
                let rowSpan = dataSource.collectionView(collectionView, rowSpanForItemIndexPath: indexPath)
                
                var itemHeight: CGFloat {
                    switch rowSpan {
                    case let .at(row):
                        let rowHeight = delegate.collectionView(collectionView, layout: self, heightForRow: row, inSection: section)
                        return rowHeight == FlexibleGridLayoutEqualRowHeightToColumnWidth ? columnWidth : rowHeight
                    case let .fromTo(startRow, endRow):
                        return (startRow...endRow).reduce(0.0, { (result, row) -> CGFloat in
                            let rowHeight = delegate.collectionView(collectionView, layout: self, heightForRow: row, inSection: section)
                            return result + (rowHeight == FlexibleGridLayoutEqualRowHeightToColumnWidth ? columnWidth : rowHeight) + CGFloat(endRow - row) * lineSpacing
                        })
                    }
                }

                var leadingColumn = 0
                var itemWidth: CGFloat {
                    switch columnSpan {
                    case let .at(column):
                        leadingColumn = column
                        return columnWidth
                    case let .fromTo(startColumn, endColumn):
                        leadingColumn = startColumn
                        return (startColumn...endColumn).reduce(0.0, { (result, column) -> CGFloat in
                            result + columnWidth + CGFloat(column) * interitemSpacing
                        })
                    }
                }

                // 4. Asks the delegate for the height of the picture and the annotation and calculates the cell frame.
                let height = itemHeight
                let width = itemWidth
                
                let columnOffset = (0..<leadingColumn).reduce(0.0) { (result, _) -> CGFloat in
                    result + columnWidth
                }
                let xOffset = columnOffset + CGFloat(leadingColumn) * interitemSpacing + sectionInsets.left
                let frame = CGRect(x: xOffset, y: yOffset[leadingColumn], width: width, height: height)

                // 5. Creates an UICollectionViewLayoutItem with the frame and add it to the cache
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = frame
                itemCache[indexPath] = attributes

                // 6. Updates the collection view content height
                contentHeight = max(contentHeight, frame.maxY)
                
                // Update y offset
                switch columnSpan {
                case let .at(column):
                    // Add item height and trailing line spacing to y offset for column
                    yOffset[column] = yOffset[column] + height + lineSpacing
                    maxY = max(maxY, yOffset[column])
                case let .fromTo(startColumn, endColumn):
                    (startColumn...endColumn).forEach { (column) in
                        // Add item height and trailing line spacing to y offset for each column
                        yOffset[column] = yOffset[column] + height + lineSpacing
                        maxY = max(maxY, yOffset[column])
                    }
                }
            }
            
            // Account for no line spacing at the end of section 
            maxY = maxY - lineSpacing

            // Footer
            let footerSize = delegate.collectionView(collectionView, layout: self, referenceSizeForFooterInSection: section)
            if footerSize.height > 0.0 {
                let footerAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, with: IndexPath(item: 0, section: section))
                footerAttributes.frame = CGRect(x: 0, y: maxY, width: contentWidth, height: footerSize.height)
                footerCache.append(footerAttributes)
            }

            // Update max y for next section
            maxY = maxY + footerSize.height + sectionInsets.bottom
            contentHeight = max(contentHeight, maxY)
        }
    }

    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {

        // Loop through the cache and look for items in the rect
        let itemLayoutAttributes = itemCache.compactMap { return $0.value }
        return (itemLayoutAttributes + headerCache + footerCache).filter { (attributes) -> Bool in
            return attributes.frame.intersects(rect)
        }
    }

    public override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if elementKind == UICollectionElementKindSectionHeader {
            return headerCache[indexPath.section]
        } else if elementKind == UICollectionElementKindSectionFooter {
            return footerCache[indexPath.section]
        }
        return nil
    }

    public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return itemCache[indexPath]
    }

}
