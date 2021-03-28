//
//  GameMediaAnimatableCompactCell.swift
//  w2p
//
//  Created by vas on 22.03.2021.
//

import UIKit

class GameMediaCell: UICollectionViewCell {
    
    @IBOutlet weak var infoContainer: UIControl!
    @IBOutlet weak var infoImageView: UIImageView!

    var staticMediaView: UIImageView? {
        get { fatalError("Need to override staticMediaView") }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupControl()
    }
    
    private func setupControl() {
        infoContainer.addTarget(self, action: #selector(touchUp), for: .touchUpInside)
    }
    
    var isLoading = false
    var id: UUID?
    
    func reload() {
        fatalError("override reload()")
    }

    @objc func touchUp() {
        reload()
    }

    func startLoadingAnimation() {
        DispatchQueue.main.async {
            self.infoContainer.isUserInteractionEnabled = false
            let image = GameAnimationSupporter.getRandomImageForAnimation()
            self.infoImageView.image = image
            
            let animation = GameAnimationSupporter.getRandomAnimation()
            animation.duration = 1
            animation.autoreverses = true
            animation.repeatCount = .infinity
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            
            self.infoContainer.alpha = 1
            self.infoContainer.layer.removeAllAnimations()
            self.infoImageView.layer.removeAllAnimations()
            self.infoImageView.layer.add(animation, forKey: "mediaCompactCellAnimation")
        }
    }
    
    func setupStaticMediaView(image: UIImage, completion: (()->Void)? = nil) {
        guard let staticMediaView = staticMediaView else {
            completion?()
            return
        }
        UIView.transition(with: staticMediaView, duration: 0.3, options: [.transitionCrossDissolve, .beginFromCurrentState]) {
            staticMediaView.image = image
        } completion: { _ in
            completion?()
        }
    }

    func showConnectionProblemMessage(duration: Double, completion: (()->Void)? = nil) {
        DispatchQueue.main.async {
            self.infoContainer.isUserInteractionEnabled = true
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
            startLoadingAnimation()
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
        infoImageView.layer.removeAllAnimations()
        infoContainer.alpha = 0
        staticMediaView?.image = nil

    }
}
