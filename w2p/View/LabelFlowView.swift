
//  FlowView.swift
//  w2p
//
//  Created by vas on 23.02.2021.
//

import UIKit


class LabelFlowView: UIView{
    
    var vertivalSpacing: CGFloat = 10
    var horizontalSpacing: CGFloat = 10
    
    override func layoutSubviews(){
        super.layoutSubviews()
        flowLayout()

    }
    override var intrinsicContentSize: CGSize{
        return CGSize(width: 0, height: calculateHeight())
    }
    
    private func flowLayout(){
        
        
    }
        
    private func layoutSubviewsLineInCenter(){
       
    }
 
    private func calculateHeight() -> CGFloat {
        guard let subviewHeight = subviews.first?.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height else {
            return .zero
        }
        var yOffset: CGFloat = 0
        var xOffset: CGFloat = 0
        let selfSize = self.bounds.size
        
        for subview in subviews{
            let subviewSize = subview.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            if subviewSize.width < selfSize.width - xOffset{
                xOffset += subviewSize.width
            } else {
                xOffset = 0
                yOffset += subviewSize.height + vertivalSpacing
                xOffset += min(subviewSize.width, selfSize.width)
            }
        }
        return xOffset == 0 ? yOffset : yOffset + subviewHeight
    }
}











