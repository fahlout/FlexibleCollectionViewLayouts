//
//  Enums.swift
//  FlexibleCollectionViewLayouts
//
//  Created by Niklas Fahl on 9/10/18.
//  Copyright © 2018 fahlout. All rights reserved.
//

import Foundation
import CoreGraphics

public enum FlexibleColumnWidth {
    case equalRatio
    case ratio(CGFloat)
    case equalTo(CGFloat)
}

public enum FlexibleGridSpan {
    case fromTo(Int, Int)
    case at(Int)
}
