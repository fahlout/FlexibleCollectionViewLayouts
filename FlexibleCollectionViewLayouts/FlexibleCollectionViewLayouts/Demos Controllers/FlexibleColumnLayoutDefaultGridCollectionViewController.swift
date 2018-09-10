//
//  FlexibleColumnLayoutDefaultGridCollectionViewController.swift
//  CollectionViewFlowTest
//
//  Created by Niklas Fahl on 9/5/18.
//  Copyright © 2018 Center for Advanced Public Safety. All rights reserved.
//

import UIKit

class FlexibleColumnLayoutDefaultGridCollectionViewController: UICollectionViewController {
    
    // Example
    struct Model {
        var id = UUID()
        
        // Add additional properties for your own model here.
    }
    
    /// Example data identifiers.
    private let models = (1...1000).map { _ in
        return Model()
    }
    
    /// An `AsyncFetcher` that is used to asynchronously fetch `DisplayData` objects.
    private let asyncFetcher = AsyncFetcher()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = UIColor.white
        navigationItem.largeTitleDisplayMode = .never
        
        // Register cell
        collectionView?.register(TextCell.self, forCellWithReuseIdentifier: "cell")
        collectionView?.register(UINib(nibName: String(describing: TitleCollectionReusableView.self), bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: String(describing: TitleCollectionReusableView.self))
        collectionView?.register(UINib(nibName: String(describing: TitleCollectionReusableView.self), bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: String(describing: TitleCollectionReusableView.self))
        
        // Set delegates
        if let layout = collectionView?.collectionViewLayout as? FlexibleColumnLayout {
            layout.delegate = self
            layout.dataSource = self
        }
    }
    
    // In order to have the layout work when switching size classes on device
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionViewLayout.invalidateLayout()
    }
}

extension FlexibleColumnLayoutDefaultGridCollectionViewController {
    
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
        cell.backgroundColor = UIColor(white: 0.8, alpha: 100)
        
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
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: String(describing: TitleCollectionReusableView.self), for: indexPath) as? TitleCollectionReusableView else {
            fatalError("Expected `\(TitleCollectionReusableView.self)` type for reuseIdentifier \(String(describing: TitleCollectionReusableView.self)). Check the configuration in Main.storyboard.")
        }
        view.titleLabel.text = "\(kind == UICollectionElementKindSectionHeader ? "Photo Feed" : "Powered by FlexibleColumnLayout")"
        view.titleLabel.textColor = .black
        view.titleLabel.font = kind == UICollectionElementKindSectionHeader ? UIFont.systemFont(ofSize: 20.0, weight: .bold) : UIFont.systemFont(ofSize: 14.0)
        view.titleLabel.textAlignment = kind == UICollectionElementKindSectionHeader ? .left : .center
        view.backgroundColor = .white
        return view
    }
}

// MARK: - Flexible Column Layout Data Source
extension FlexibleColumnLayoutDefaultGridCollectionViewController: FlexibleColumnLayoutDataSource {
    func collectionView(_ collectionView:UICollectionView, numberOfColumnsInSection section:Int) -> Int {
        if collectionView.frame.width > collectionView.frame.height {
            return 7
        } else {
            if traitCollection.verticalSizeClass == .regular && traitCollection.horizontalSizeClass == .regular {
                return 5
            }
            return 4
        }
    }
}

// MARK: - Flexible Column Layout Delegate
extension FlexibleColumnLayoutDefaultGridCollectionViewController : FlexibleColumnLayoutDelegate {
    // Size for header and footer
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: 65.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: 30.0)
    }
    
    // Spacing and insets
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, lineSpacingForSection section: Int) -> CGFloat {
        return 1.5
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, interitemSpacingForSection section: Int) -> CGFloat {
        return 1.5
    }
}
