//
//  SettingsViewController.swift
//  w2p
//
//  Created by vas on 13.02.2021.
//

import UIKit

class SettingsViewController: UIViewController{
    
    @IBAction func hapticFeedbackSwitched(_ sender: UISwitch) {
    }
    
    @IBAction func darkModeSwitched(_ sender: UISwitch) {
    }
    
    @IBAction func clearFavoritesTapped(_ sender: UIButton) {
    }
    
    @IBAction func clearCacheTapped(_ sender: UIButton) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(startHeartAnimation), name: UIApplication.didBecomeActiveNotification, object: nil)
        
    }
    
    @IBOutlet weak var heartImage: UIImageView!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        heartImage.alpha = 0
        

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startHeartAnimation()
    }
    
    @objc private func startHeartAnimation(){
        let animation = CABasicAnimation(keyPath: "transform.scale")
        
        animation.duration = 1
        animation.autoreverses = true
        animation.fromValue = 1
        animation.toValue = 0.7
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.repeatCount = .infinity
        
        heartImage.layer.add(animation, forKey: "beating animation")
        UIView.animate(withDuration: 0.65) {
            self.heartImage.alpha = 1
        }
        
    }
   
}
