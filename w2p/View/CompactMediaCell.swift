//
//  GameMediaAnimatableCompactCell.swift
//  w2p
//
//  Created by vas on 22.03.2021.
//

import UIKit

class CompactMediaCell: UICollectionViewCell {
    
    @IBOutlet weak var infoContainer: UIView!
    @IBOutlet weak var infoImageView: UIImageView!
    @IBOutlet weak var staticMediaView: UIImageView!
    
    var isLoading = false
    var id: UUID?

    func startLoadingAnimation(duration: Double, completion: (()-> Void)? = nil ) {
        DispatchQueue.main.async {
            let image = GameAnimationSupporter.getRandomImageForAnimation()
            self.infoImageView.image = image
            
            let animation = GameAnimationSupporter.getRandomAnimation()
            animation.duration = 1
            animation.autoreverses = true
            animation.repeatCount = .infinity
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            
            self.infoImageView.layer.add(animation, forKey: "mediaCompactCellAnimation")
            UIView.animate(withDuration: duration, delay: 0, options: .beginFromCurrentState) {
                self.infoContainer.alpha = 1
            } completion: { _ in
                completion?()
            }
        }
    }
    
    func setupStaticMediaView(image: UIImage, completion: (()->Void)? = nil) {
        UIView.transition(with: staticMediaView, duration: 0.3, options: [.transitionCrossDissolve, .beginFromCurrentState]) {
            self.staticMediaView.image = image
        } completion: { _ in
            self.finishShowingInfoContainer(duration: 0)
            completion?()
        }
    }

    func showConnectionProblemMessage(duration: Double, completion: (()->Void)? = nil) {
        DispatchQueue.main.async {
            self.infoImageView.image = UIImage(named: "connection")
            UIView.animate(withDuration: duration,delay: 0, options: .beginFromCurrentState) {
                self.infoContainer.alpha = 1
            } completion: { _ in
                completion?()
            }
        }
    }
    
    func updateAnimationIfNeeded() {
        if isLoading {
            infoImageView.layer.removeAllAnimations()
            startLoadingAnimation(duration: 0)
        }
    }
    

    func finishShowingInfoContainer(duration: Double, completion: (()->Void)? = nil) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: duration) {
                self.infoContainer.alpha = 0
            } completion: { _ in
                self.infoImageView.layer.removeAllAnimations()
                completion?()
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        id = nil
        infoContainer.alpha = 0
        infoImageView.layer.removeAllAnimations()
        staticMediaView.image = nil

    }
    
}
