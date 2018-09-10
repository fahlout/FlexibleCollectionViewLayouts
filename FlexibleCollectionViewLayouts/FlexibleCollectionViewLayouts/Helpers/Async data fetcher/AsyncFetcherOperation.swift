/*
See LICENSE folder for this sample’s licensing information.

Abstract:
An `Operation` subclass used by `AsyncFetcher` to mimic slow network requests for data.
*/

import UIKit

class AsyncFetcherOperation: Operation {
    // MARK: Properties

    /// The `UUID` that the operation is fetching data for.
    let identifier: UUID
    let imageId: Int

    /// The `DisplayData` that has been fetched by this operation.
    private(set) var fetchedData: DisplayData?

    // MARK: Initialization

    init(identifier: UUID, imageId: Int) {
        self.identifier = identifier
        self.imageId = imageId
    }

    // MARK: Operation overrides

    override func main() {
        // Wait for a second to mimic a slow operation.
//        Thread.sleep(until: Date().addingTimeInterval(1))
//        let imageId = Int(arc4random_uniform(1000) + 1)
        guard let url = URL(string: "https://picsum.photos/800/?image=\(imageId)"), !isCancelled else { return }
        guard let image = try? UIImage(data: Data(contentsOf: url)) else { return }
        
        print("fetching for \(identifier)")
        
        let displayData = DisplayData()
        displayData.image = image
        fetchedData = displayData
    }
}
