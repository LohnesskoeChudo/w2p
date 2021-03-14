//
//  SettingsViewController.swift
//  w2p
//
//  Created by vas on 13.02.2021.
//

import UIKit

class SettingsViewController: UIViewController{
    
    let mediaDispatcher = GameMediaDispatcher()
    
    @IBOutlet weak var hapticSwitch: UISwitch!
    
    @IBOutlet weak var darkModeSwitch: UISwitch!
    
    
    @IBAction func hapticFeedbackSwitched(_ sender: UISwitch) {
        GlobalSettings.shared.hapticFeedback.toggle()
    }
    
    @IBAction func darkModeSwitched(_ sender: UISwitch) {
        GlobalSettings.shared.darkMode.toggle()
        ThemeManager.updateUIAppearance()
    }
    
    @IBAction func clearFavoritesTapped(_ sender: UIButton) {
        FeedbackManager.generateFeedbackForButtonsTapped()
        showClearFavoritesAVController()
    }
    
    @IBAction func clearCacheTapped(_ sender: UIButton) {
        FeedbackManager.generateFeedbackForButtonsTapped()
        showClearCacheAVController()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(startHeartAnimation), name: UIApplication.didBecomeActiveNotification, object: nil)
        setupUI()
    }
    
    private func setupUI() {
        hapticSwitch.isOn = GlobalSettings.shared.hapticFeedback
        darkModeSwitch.isOn = GlobalSettings.shared.darkMode
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
    
    
    private func showClearFavoritesAVController(){
        let avc = UIAlertController(title: nil , message: "Do you really want to clear favorites?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel , handler: nil)
        avc.addAction(cancelAction)
        let confirmAction = UIAlertAction(title: "Delete", style: .destructive) {
            _ in
            self.mediaDispatcher.clearFavorites()
        }
        avc.addAction(confirmAction)
        present(avc, animated: true, completion: nil)
    }
    
    private func showClearCacheAVController(){
        let avc = UIAlertController(title: nil, message: "Do you really want to clear cache?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel , handler: nil)
        avc.addAction(cancelAction)
        let confirmAction = UIAlertAction(title: "Delete", style: .destructive) {
            _ in
            self.mediaDispatcher.clearImageCache()
        }
        avc.addAction(confirmAction)
        present(avc, animated: true, completion: nil)
    }
   
}
