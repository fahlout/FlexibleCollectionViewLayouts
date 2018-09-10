//
//  FlexibleGridLayoutAdvancedGridCollectionViewController.swift
//  CollectionViewFlowTest
//
//  Created by Niklas Fahl on 9/6/18.
//  Copyright © 2018 Center for Advanced Public Safety. All rights reserved.
//

import UIKit

class FlexibleGridLayoutAdvancedGridCollectionViewController: UICollectionViewController {

    // Example
    struct Model {
        var id = UUID()
        
        // Add additional properties for your own model here.
    }
    
    /// Example data identifiers.
    private let models = (1...306).map { _ in
        return Model()
    }
    
    /// An `AsyncFetcher` that is used to asynchronously fetch `DisplayData` objects.
    private let asyncFetcher = AsyncFetcher()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.backgroundColor = UIColor.white
        navigationItem.largeTitleDisplayMode = .never

        // Register cell classes
        collectionView?.register(TextCell.self, forCellWithReuseIdentifier: "cell")
        
        // Set delegates
        if let layout = collectionView?.collectionViewLayout as? FlexibleGridLayout {
            layout.delegate = self
            layout.dataSource = self
        }
    }
    
    // In order to have the layout work when switching size classes on device
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionViewLayout.invalidateLayout()
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return models.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? TextCell else {
            fatalError("Expected `\(TextCell.self)` type for reuseIdentifier \("cell"). Check the configuration in Main.storyboard.")
        }
        cell.backgroundColor = UIColor(white: 0.85, alpha: 100)
//        cell.label.text = "\(indexPath.item)"
        
        let model = models[indexPath.item]
        let id = model.id
        cell.representedId = id

        // Check if the `asyncFetcher` has already fetched data for the specified identifier.
        if let fetchedData = asyncFetcher.fetchedData(for: id) {
            // The data has already been fetched and cached; use it to configure the cell.
            cell.configure(with: fetchedData)
        } else {
            // There is no data available; clear the cell until we've fetched data.
            cell.configure(with: nil)

            // Ask the `asyncFetcher` to fetch data for the specified identifier.
            asyncFetcher.fetchAsync(id, imageId: indexPath.item + 20) { fetchedData in
                DispatchQueue.main.async {
                    /*
                     The `asyncFetcher` has fetched data for the identifier. Before
                     updating the cell, check if it has been recycled by the
                     collection view to represent other data.
                     */
                    guard cell.representedId == id else { return }

                    // Configure the cell with the fetched image.
                    cell.configure(with: fetchedData)
                }
            }
        }
        return cell
    }
}

extension FlexibleGridLayoutAdvancedGridCollectionViewController: FlexibleGridLayoutDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfColumnsInSection section: Int) -> Int {
        let isRegularRegular = traitCollection.verticalSizeClass == .regular && traitCollection.horizontalSizeClass == .regular
        return isRegularRegular ? 5 : 3
    }
    
    func collectionView(_ collectionView: UICollectionView, rowSpanForItemIndexPath indexPath: IndexPath) -> FlexibleGridSpan {
        let isRegularRegular = traitCollection.verticalSizeClass == .regular && traitCollection.horizontalSizeClass == .regular
        let groupSize = isRegularRegular ? 17 : 9
        let topGroupCutoff = isRegularRegular ? 7 : 3
        let topSmallCutoff = isRegularRegular ? 5 : 1
        let numberOfColumns = isRegularRegular ? 5 : 3
        
        let itemIdentifier = indexPath.item % groupSize
        if itemIdentifier < topGroupCutoff {
            if (indexPath.item / groupSize) % 2 == 0 {
                // Even
                if (0...topSmallCutoff).contains(itemIdentifier) {
                    return .at(itemIdentifier % 2)
                }
                return .fromTo(itemIdentifier, itemIdentifier + 1)
            } else {
                // Odd
                if (1...topSmallCutoff + 1).contains(itemIdentifier) {
                    return .at(itemIdentifier % 2)
                }
                return .fromTo(itemIdentifier, itemIdentifier + 1)
            }
        }
        return .at(indexPath.item % numberOfColumns)
    }
    func collectionView(_ collectionView: UICollectionView, columnSpanForItemIndexPath indexPath: IndexPath) -> FlexibleGridSpan {
        let isRegularRegular = traitCollection.verticalSizeClass == .regular && traitCollection.horizontalSizeClass == .regular
        let groupSize = isRegularRegular ? 17 : 9
        let topGroupCutoff = isRegularRegular ? 7 : 3
        let topSmallCutoff = isRegularRegular ? 5 : 1
        let numberOfColumns = isRegularRegular ? 5 : 3
        let topSmallItemColumns = isRegularRegular ? 3 : 1
        let largeItemColumnSpan = 2
        
        let itemIdentifier = indexPath.item % groupSize
        if itemIdentifier < topGroupCutoff {
            if (indexPath.item / groupSize) % 2 == 0 {
                // Even
                if (0...topSmallCutoff).contains(itemIdentifier) {
                    return .at(itemIdentifier % topSmallItemColumns)
                }
                return .fromTo(numberOfColumns - largeItemColumnSpan, numberOfColumns - 1)
            } else {
                // Odd
                if (1...topSmallCutoff + 1).contains(itemIdentifier) {
                    return .at(((itemIdentifier - 1) % topSmallItemColumns) + 2)
                }
                return .fromTo(0, 1)
            }
        }
        
        return .at((itemIdentifier - topGroupCutoff) % numberOfColumns)
    }
}

extension FlexibleGridLayoutAdvancedGridCollectionViewController: FlexibleGridLayoutDelegate {
    // Spacing and insets
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, lineSpacingForSection section: Int) -> CGFloat {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, interitemSpacingForSection section: Int) -> CGFloat {
        return 1
    }
}
