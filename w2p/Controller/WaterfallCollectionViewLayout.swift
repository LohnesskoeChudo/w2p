//
//  WaterfallCollectionViewLayout.swift
//  w2p
//
//  Created by vas on 13.02.2021.
//

import UIKit
    
class WaterfallCollectionViewLayout: UICollectionViewLayout{
    
    var delegate: WaterfallCollectionViewLayoutDelegate?
    var cellPadding: CGFloat = 0
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
    
    var footerAttrs: UICollectionViewLayoutAttributes?
    var footerIsPresented: Bool = false

    private func initialLayout(){
        if !cache.isEmpty {return}
        guard let collectionView = collectionView , let delegate = delegate else {return}
        xOffset = [CGFloat]()
        for columnIndex in 0..<columns{
            xOffset.append((CGFloat(columnIndex) * columnWidth) + delegate.spacing * CGFloat(columnIndex + 1))
        }
        yOffset = .init(repeating: delegate.upperSpacing, count: columns)
        for item in 0..<collectionView.numberOfItems(inSection: 0){
            let indexPath = IndexPath(item: item, section: 0)
            layoutItemAt(indexPath: indexPath)
        }
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
        
        var height: CGFloat = max(frameHeight, contentHeight) + (delegate?.spacing ?? 0)
        
        if let footerAttrs = footerAttrs {
            height += (footerAttrs.frame.height) + (delegate?.spacing ?? 0)
        }
        
        return CGSize(width: contentWidth, height: height)
    }
    
    override func prepare() {
        initialLayout()
    }
    
    //MARK: - using binary search to find elements
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        
        
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
        
        
        
        
        if footerAttrs != nil {
            visibleLayoutAttributes.append(footerAttrs!)
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
        if indexPath.section == 0 {
            return cache[indexPath.item]
        }
        if indexPath.section == 1 {
            return footerAttrs
        }
        return nil
    }

    override func invalidateLayout() {
        super.invalidateLayout()
        cache = []
    }
    

    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        
        let maxItem = cache.count - 1
        for item in updateItems{
            
            if item.indexPathBeforeUpdate?.item == -1, item.indexPathAfterUpdate == nil{
                removeFooter()
            }
                
            if item.indexPathAfterUpdate?.item == -1, item.indexPathBeforeUpdate == nil{
                addFooter()
            }

            guard let indexPath = item.indexPathAfterUpdate, indexPath.item > maxItem, item.indexPathBeforeUpdate == nil else {continue}
            layoutItemAt(indexPath: indexPath)
        }
    }
    

    private func addFooter() {
        guard let collectionView = collectionView else {return}
        let attrs = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: WaterfallSupplementaryViewKind.footer.rawValue, with: IndexPath(item: -1, section: 1))
        if let footer = collectionView.supplementaryView(forElementKind: WaterfallSupplementaryViewKind.footer.rawValue, at: IndexPath(item:cache.count, section: 0)) {
            let footerSize = footer.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            attrs.frame = CGRect(origin: CGPoint(x: (collectionView.frame.width - footerSize.width) / 2 , y: (yOffset.max() ?? 0) + (delegate?.spacing ?? 0)) , size: footerSize)
            footerAttrs = attrs
        }
    }
    
    private func removeFooter(){
        footerAttrs = nil
    }
    
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        print(itemIndexPath.item, itemIndexPath.section)
        
        if itemIndexPath.section == 0{
            let attrs = cache[itemIndexPath.item].copy() as! UICollectionViewLayoutAttributes
            attrs.alpha = 0
            return attrs
        }
        
        return nil

    }
    
}


protocol WaterfallCollectionViewLayoutDelegate: AnyObject {
    
    func heightForCell(at indexPath: IndexPath) -> CGFloat
    
    var numberOfColumns: Int {get}
    
    var spacing: CGFloat {get}
    
    var upperSpacing: CGFloat {get}
    
}

enum WaterfallSupplementaryViewKind: String{
    case footer = "footer"
}
