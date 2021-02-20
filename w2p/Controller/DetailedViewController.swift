//
//  DetailedViewController.swift
//  w2p
//
//  Created by vas on 13.02.2021.
//

import UIKit

class DetailedViewController: UIViewController{
    
    var gameItem: GameItem!
    var imageBlurrer = ImageBlurrer()
    
    @IBOutlet weak var coverView: UIImageView!
    @IBOutlet weak var blurredBackground: UIImageView!
    @IBOutlet weak var coverWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var coverHeightConstraint: NSLayoutConstraint!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        blurredBackground.image = imageBlurrer.blurImage(with: UIImage(named: "test")!, radius: 30)
        coverView.layer.borderWidth = 3
        coverView.layer.borderColor = UIColor.black.cgColor
        coverView.image = UIImage(named: "test")
    }
    
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        layoutCover()
        setupCover()
    }
    
    private func setupCover(){
        /*
        blurredBackground.image = imageBlurrer.blurImage(with: UIImage(data: (gameItem.cover?.data)!)!, radius: 25)
        coverView.image = UIImage(data: (gameItem.cover?.data)!)!
 */
    }
    
    private func layoutCover(){
        
        let heightPercentage: CGFloat = 0.66
        
        
        guard let aspect = gameItem.cover?.aspect else {return}
        if CGFloat(aspect) > (view.frame.height * heightPercentage) / view.frame.width {
            print("<")
            coverHeightConstraint.constant = view.frame.height * heightPercentage
            coverWidthConstraint.constant = (1 / CGFloat(aspect)) * (view.frame.height * heightPercentage)
            
        } else {
            print(">")
            coverWidthConstraint.constant = view.frame.width
            coverHeightConstraint.constant = view.frame.width * CGFloat(aspect)
        }
    }
}
