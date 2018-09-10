//
//  FlexibleGridLayout.swift
//
//  Created by Niklas Fahl on 8/29/18.
//  Copyright © 2018 fahlout. All rights reserved.
//

import UIKit

public class FlexibleGridLayout: UICollectionViewLayout {
    
    public weak var delegate: FlexibleGridLayoutDelegate?
    public weak var dataSource: FlexibleGridLayoutDataSource?

    private(set) var itemCache = [IndexPath: UICollectionViewLayoutAttributes]()
    private(set) var sectionBackgroundCache = [UICollectionViewLayoutAttributes]()
    private(set) var headerCache = [UICollectionViewLayoutAttributes]()
    private(set) var footerCache = [UICollectionViewLayoutAttributes]()
    private(set) var cachedContentSize: CGSize = .zero

    override open var collectionViewContentSize: CGSize {
        return self.cachedContentSize
    }

    public override func prepare() {
        super.prepare()

        guard let collectionView = collectionView, let delegate = delegate, let dataSource = dataSource else { return }

        // Reset cache
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
            
            // Header
            let headerSize = delegate.collectionView(collectionView, layout: self, referenceSizeForHeaderInSection: section)
            if headerSize.height > 0.0 {
                let headerAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, with: IndexPath(item: 0, section: section))
                headerAttributes.frame = CGRect(x: 0, y: maxY, width: contentWidth - sectionLeftRightInset, height: headerSize.height)
                headerCache.append(headerAttributes)
            }

            maxY = maxY + headerSize.height
            var yOffset = [CGFloat](repeating: maxY, count: numberOfColumns)
            let columnWidth = (contentWidth - sectionLeftRightInset - (CGFloat(numberOfColumns - 1) * interitemSpacing)) / CGFloat(numberOfColumns)

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
                            result + columnWidth + CGFloat(endColumn - column) * interitemSpacing
                        })
                    }
                }

                let height = itemHeight
                let width = itemWidth
                
                let columnOffset = (0..<leadingColumn).reduce(0.0) { (result, _) -> CGFloat in
                    result + columnWidth
                }
                let xOffset = columnOffset + CGFloat(leadingColumn) * interitemSpacing + sectionInsets.left
                let frame = CGRect(x: xOffset, y: yOffset[leadingColumn], width: width, height: height)

                // Creates an UICollectionViewLayoutItem with the frame and add it to the cache
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = frame
                itemCache[indexPath] = attributes
                
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
