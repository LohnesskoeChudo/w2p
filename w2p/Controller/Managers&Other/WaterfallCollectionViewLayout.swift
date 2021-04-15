//
//  WaterfallCollectionViewLayout.swift
//  w2p
//
//  Created by vas on 13.02.2021.
//

import UIKit
    
class WaterfallCollectionViewLayout: UICollectionViewLayout{
    
    var delegate: WaterfallCollectionViewLayoutDelegate?
    private var cache = [UICollectionViewLayoutAttributes]()
    
    var contentWidth: CGFloat {
        guard let collectionView = collectionView else { return 0 }
        let insets = collectionView.contentInset
        let width = collectionView.bounds.width - (insets.left + insets.right)
        return width
    }
    
    var columns: Int{
        delegate?.numberOfColumns ?? 0
    }
    
    var columnWidth: CGFloat{
        guard let delegate = delegate else { return 0}
        if columns > 0{
            let columnWidth = (contentWidth - (delegate.spacing * CGFloat((delegate.numberOfColumns + 1)))) / CGFloat(columns)
            return columnWidth
        }
        return 0
    }
    
    var xOffset: [CGFloat] = []
    var yOffset: [CGFloat] = []
    var headerAttrs: UICollectionViewLayoutAttributes?
    var footerAttrs: UICollectionViewLayoutAttributes?

    private func initialLayout(){
        guard let delegate = delegate, let cvWidth = collectionView?.frame.width else {return}
        cache = []
        var additionalHeight: CGFloat = 0
        if let height = delegate.headerHeight {
            
            headerAttrs = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, with: IndexPath(item: 0, section: 0))
            headerAttrs?.frame = CGRect(x: delegate.spacing, y: delegate.upperSpacing, width: cvWidth - 2 * delegate.spacing , height: height)
            headerAttrs?.alpha = 1
            additionalHeight += height
        }
        additionalHeight += delegate.upperSpacing
        xOffset = [CGFloat]()
        for columnIndex in 0..<columns{
            xOffset.append((CGFloat(columnIndex) * columnWidth) + delegate.spacing * CGFloat(columnIndex + 1))
        }
        yOffset = .init(repeating: additionalHeight, count: columns)
    }
    

    private func layoutItemAt(indexPath: IndexPath){
        guard let delegate = delegate else {return}
        let cellHeight = delegate.heightForCell(at: indexPath)
        var minHeightColumn: Int = 0
        var minHeight: CGFloat = .infinity
        for column in (0..<columns).reversed(){
            if yOffset[column] <= minHeight{
                minHeight = yOffset[column]
                minHeightColumn = column
            }
        }
        let columnToInsert = minHeightColumn
        let offsetPoint = CGPoint(x: xOffset[columnToInsert], y: yOffset[columnToInsert] + delegate.spacing)
        let cellSize = CGSize(width: columnWidth, height: cellHeight)
        yOffset[columnToInsert] = yOffset[columnToInsert] + cellHeight + delegate.spacing
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        attributes.frame = CGRect(origin: offsetPoint, size: cellSize)
        attributes.alpha = 1
        cache.append(attributes)
    }
    
    override var collectionViewContentSize: CGSize {
        guard let frameHeight = collectionView?.frame.height, let contentHeight = yOffset.max() else {
            return .zero
        }
        
        let height: CGFloat = max(frameHeight, contentHeight) + (delegate?.spacing ?? 0)
        
        return CGSize(width: contentWidth, height: height)
    }

    //MARK: - using binary search to find elements
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
        if let headerAttrs = headerAttrs, headerAttrs.frame.intersects(rect) {
            visibleLayoutAttributes.append(headerAttrs)
        }
        if cache.count > 0 {
            let indexOfPredecessorOfFirstVisibleItem = customBinarySearch(collection: cache,trueProperty: {
                index in
                if index + 1 >= cache.count || index == 0 {
                    return true
                }
                return !cache[index].frame.intersects(rect) && cache[index + 1].frame.intersects(rect)
            }, lessThanProperty: {
                index in
                let attr = cache[index]
                let lowerBound = attr.frame.origin.y + attr.frame.height
                if lowerBound < rect.origin.y {
                    return true
                }
                return false
            })
            var index: Int = indexOfPredecessorOfFirstVisibleItem ?? 0
            if indexOfPredecessorOfFirstVisibleItem != nil {
                index = max(0, indexOfPredecessorOfFirstVisibleItem! - 6)
            } else {
                index = 0
            }
            let lowerRectBoundOffset = rect.height + rect.origin.y
            var currentAttrs: UICollectionViewLayoutAttributes = cache[index]
            while currentAttrs.frame.origin.y < lowerRectBoundOffset{
                visibleLayoutAttributes.append(currentAttrs)
                index += 1
                if index >= cache.count{
                    break
                }
                currentAttrs = cache[index]
            }
        }
        return visibleLayoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if elementKind == UICollectionView.elementKindSectionHeader {
            return headerAttrs
        } else if elementKind == UICollectionView.elementKindSectionFooter {
            return nil
        }
        return nil
    }

    override func initialLayoutAttributesForAppearingSupplementaryElement(ofKind elementKind: String, at elementIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if elementKind == UICollectionView.elementKindSectionHeader {
            guard let headerAttrs = self.headerAttrs else { return nil }
            let attrs = UICollectionViewLayoutAttributes()
            attrs.frame = headerAttrs.frame
            attrs.alpha = 0
            return attrs
        } else if elementKind == UICollectionView.elementKindSectionFooter {
            //CHECK
            guard let footerAttrs = self.footerAttrs else { return nil }
            let attrs = UICollectionViewLayoutAttributes()
            attrs.frame = footerAttrs.frame
            attrs.alpha = 0
            return attrs
        }
        return nil
    }
    
    override func finalLayoutAttributesForDisappearingSupplementaryElement(ofKind elementKind: String, at elementIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if elementKind == UICollectionView.elementKindSectionHeader {
            guard let headerAttrs = self.headerAttrs else { return nil }
            let attrs = UICollectionViewLayoutAttributes()
            attrs.frame = headerAttrs.frame
            attrs.alpha = 0
            return attrs
        } else if elementKind == UICollectionView.elementKindSectionFooter {
            //CHECK
            guard let footerAttrs = self.footerAttrs else { return nil }
            let attrs = UICollectionViewLayoutAttributes()
            attrs.frame = footerAttrs.frame
            attrs.alpha = 0
            return attrs
        }
        return nil
    }
    
    override class var invalidationContextClass: AnyClass {
        WFLayoutInvalidationContext.self
    }
    
    override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
        if let context = context as? WFLayoutInvalidationContext {
            if context.action == WFInvalidationAction.insertion {
                if let insertedIPs = context.indexPaths {
                    for insertedItemIP in insertedIPs {
                        layoutItemAt(indexPath: insertedItemIP)
                    }
                    collectionView?.insertItems(at: insertedIPs)
                }
            }
            if context.action == WFInvalidationAction.rebuild {
                initialLayout()
                collectionView?.reloadData()
            }
        }
        super.invalidateLayout(with: context)
    }
    
    /*
    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        let maxItem = cache.count - 1
        for item in updateItems{
            guard let indexPath = item.indexPathAfterUpdate, indexPath.item > maxItem, item.indexPathBeforeUpdate == nil else {continue}
            layoutItemAt(indexPath: indexPath)
        }
    } */
    
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attrs = cache[itemIndexPath.item].copy() as! UICollectionViewLayoutAttributes
        attrs.alpha = 0
        return attrs
    }
}


protocol WaterfallCollectionViewLayoutDelegate: AnyObject {
    var numberOfColumns: Int {get}
    var spacing: CGFloat {get}
    var upperSpacing: CGFloat {get}
    var headerHeight: CGFloat? {get}
    func heightForCell(at indexPath: IndexPath) -> CGFloat
}
