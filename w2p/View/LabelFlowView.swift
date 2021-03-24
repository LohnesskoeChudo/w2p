
//  FlowView.swift
//  w2p
//
//  Created by vas on 23.02.2021.
//

import UIKit


class LabelFlowView: UIView{
    
    var vertivalSpacing: CGFloat = 10
    var horizontalSpacing: CGFloat = 10
    var height: CGFloat = 0
    
    override func layoutSubviews(){
        super.layoutSubviews()
        flowLayout()
        invalidateIntrinsicContentSize()
    }
    
    override var intrinsicContentSize: CGSize{
        return CGSize(width: 0, height: height)
    }
    
    private func flowLayout(){
            
        guard let subviewHeight = subviews.first?.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height else {return}

        var lineBuffer = [(UIView, CGFloat)]()
        var yOffset: CGFloat = 0
        var subviewsLineWidth: CGFloat = 0
        var subviewIndex = 0
        while subviewIndex < subviews.count {
            
            let subview = subviews[subviewIndex]
            let subviewWidth = subview.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).width
            
            let lineWidth = subviewsLineWidth + subviewWidth + CGFloat(lineBuffer.count) * horizontalSpacing
            
            if bounds.width > lineWidth {
                lineBuffer.append((subview, subviewWidth))
                subviewsLineWidth += subviewWidth
                subviewIndex += 1
            } else {
                if lineBuffer.isEmpty {
                    layoutSubviewsLineInCenter(subviews: [(subview, min(bounds.width,subviewWidth))], yOffset: yOffset, subviewHeight: subviewHeight, lineWidth: bounds.width)
                    subviewIndex += 1
                } else {
                    layoutSubviewsLineInCenter(subviews: lineBuffer, yOffset: yOffset, subviewHeight: subviewHeight, lineWidth: subviewsLineWidth  + CGFloat(max(lineBuffer.count - 1, 0)) * horizontalSpacing)
                }
                subviewsLineWidth = 0
                lineBuffer = []
                yOffset += subviewHeight + vertivalSpacing
            }
        }
        if !lineBuffer.isEmpty {
            layoutSubviewsLineInCenter(subviews: lineBuffer, yOffset: yOffset, subviewHeight: subviewHeight, lineWidth: subviewsLineWidth  + CGFloat(max(lineBuffer.count - 1, 0)) * horizontalSpacing)
            yOffset += subviewHeight
        } else {
            yOffset -= vertivalSpacing
        }
        height = yOffset
    }
        
    private func layoutSubviewsLineInCenter(subviews: [(UIView, CGFloat)], yOffset: CGFloat, subviewHeight: CGFloat, lineWidth: CGFloat){
        
        var offset = (bounds.width - lineWidth) / 2

        for (subview, width) in subviews {
            subview.frame = CGRect(x: offset, y: yOffset, width: width, height: subviewHeight)
            offset += width + horizontalSpacing
        }
    }
}











