//
//  WFLayoutInvalidationContext.swift
//  w2p
//
//  Created by vas on 14.03.2021.
//

import UIKit

class WFLayoutInvalidationContext: UICollectionViewLayoutInvalidationContext {
    
    var action: WFInvalidationAction?
    var indexPaths: [IndexPath]?
}

enum WFInvalidationAction {
    case insertion
    case rebuild
}
