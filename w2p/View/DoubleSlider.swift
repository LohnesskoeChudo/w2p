//
//  DoubleSlider.swift
//  w2p
//
//  Created by vas on 25.02.2021.
//

import UIKit

class DoubleSlider: UIControl{
    
    
    var upperValue: CGFloat
    var lowerValue: CGFloat
    var maxValue: CGFloat
    var minValue: CGFloat
    weak var delegate: DoubleSliderDelegate?
    
    private let track = CALayer()
    private let upperThumb = CALayer()
    private let lowerThumb = CALayer()
    
    private var previousLocation = CGPoint()
    
    init(frame: CGRect, maxValue: CGFloat, minValue: CGFloat, thumbColor: UIColor, trackColor: UIColor){
        self.maxValue = maxValue
        self.minValue = minValue
        self.upperValue = maxValue
        self.lowerValue = minValue
        
        super.init(frame: frame)
        track.backgroundColor = trackColor.cgColor
        self.layer.addSublayer(track)
        
        upperThumb.backgroundColor = thumbColor.cgColor
        self.layer.addSublayer(upperThumb)
        
        lowerThumb.backgroundColor = thumbColor.cgColor
        self.layer.addSublayer(lowerThumb)
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPan))
        panGestureRecognizer.maximumNumberOfTouches = 1
        addGestureRecognizer(panGestureRecognizer)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not implemented")
    }
    
    override func layoutSubviews() {
        updateAppeareance()
    }
    
    func updateAppeareance(){
        track.frame = bounds.insetBy(dx: sizeForThumb.width / 2, dy: bounds.height / 4)
        track.cornerRadius = bounds.height / 4
        updateThumbsFrames()
        upperThumb.cornerRadius = upperThumb.bounds.width / 2
        lowerThumb.cornerRadius = lowerThumb.bounds.width / 2
    }
    
    private func updateThumbsFrames(){
        upperThumb.frame = CGRect(origin: upperThumbOrigin(for: upperValue) , size: sizeForThumb)
        lowerThumb.frame = CGRect(origin: lowerThumbOrigin(for: lowerValue), size: sizeForThumb)
    }
    
    private func position(for value: CGFloat) -> CGFloat{
        let total = maxValue - minValue
        let distanceFromStart = value - minValue
        let thumbWidth = sizeForThumb.width
        return thumbWidth + ((bounds.width - 2 * thumbWidth) * (distanceFromStart / total))
    }
    
    private func upperThumbOrigin(for value: CGFloat) -> CGPoint{
        let x = position(for: value)
        return CGPoint(x: x, y: 0)
    }
    
    private func lowerThumbOrigin(for value: CGFloat) -> CGPoint{
        let x = position(for: value) -  sizeForThumb.width
        return CGPoint(x: x, y: 0)
    }
    
    private var sizeForThumb: CGSize {
        CGSize(width: self.bounds.height, height: self.bounds.height)
    }
    
    var upperThumbIsActive = false
    var lowerThumbIsActive = false
    
    @objc func didPan(sender: UIPanGestureRecognizer){
        switch sender.state {
        case .began:
            previousLocation = sender.location(in: self)
            if upperThumb.frame.contains(previousLocation){
               upperThumbIsActive = true
            } else if lowerThumb.frame.contains(previousLocation){
                   lowerThumbIsActive = true
            }
        case .changed:
            let location = sender.location(in: self)
            let deltaLocation = location.x - previousLocation.x
            let deltaValue = deltaLocation * (maxValue - minValue) / (bounds.width - sizeForThumb.width * 2)
            previousLocation = location
            
            if lowerThumbIsActive {
                lowerValue += deltaValue
                lowerValue = boundValue(value: lowerValue, maxValue: upperValue, minValue: minValue)
                delegate?.sliderValuesChanged(newLowerValue: lowerValue, newUpperValue: upperValue)
            } else if upperThumbIsActive {
                upperValue += deltaValue
                upperValue = boundValue(value: upperValue, maxValue: maxValue, minValue: lowerValue)
                delegate?.sliderValuesChanged(newLowerValue: lowerValue, newUpperValue: upperValue)
            }
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            updateThumbsFrames()
            CATransaction.commit()
        case .ended:
            lowerThumbIsActive = false
            upperThumbIsActive = false
        default:
            return
        }
    }

    private func boundValue(value: CGFloat, maxValue: CGFloat, minValue: CGFloat) -> CGFloat{
        min(max(minValue, value), maxValue)
    }
}

protocol DoubleSliderDelegate: AnyObject{
    
    func sliderValuesChanged(newLowerValue: CGFloat, newUpperValue: CGFloat)
    
}
