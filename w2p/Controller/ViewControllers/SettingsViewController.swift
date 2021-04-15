//
//  SettingsViewController.swift
//  w2p
//
//  Created by vas on 13.02.2021.
//

import UIKit

class SettingsViewController: UIViewController{
    
    private let mediaDispatcher = Resolver.shared.container.resolve(PMediaDispatcher.self)!
    private let cacheManager = Resolver.shared.container.resolve(PCacheManager.self)!
    
    @IBOutlet private weak var hapticSwitch: UISwitch!
    @IBOutlet private weak var heartImage: UIImageView!
    @IBOutlet private weak var darkModeSwitch: UISwitch!
    @IBOutlet private weak var cacheImagesSizeLabel: UILabel!
    
    @IBAction private func hapticFeedbackSwitched(_ sender: UISwitch) {
        GlobalSettings.shared.hapticFeedback.toggle()
    }
    
    @IBAction private func darkModeSwitched(_ sender: UISwitch) {
        GlobalSettings.shared.darkMode.toggle()
        ThemeManager.updateUIAppearance()
    }
    
    @IBAction private func clearFavoritesTapped(_ sender: UIButton) {
        FeedbackManager.generateFeedbackForButtonsTapped()
        showClearFavoritesAVController()
    }
    
    @IBAction private func clearCacheTapped(_ sender: UIButton) {
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
    
    private func updateCacheImagesSizeLabel() {
        let cacheImagesSize = UserDefaults.standard.double(forKey: UserDefaults.keyForCachedImagesSize) / (1024 * 1024)
        cacheImagesSizeLabel.text = "\(String(format: "%.1f", cacheImagesSize)) Mb"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        heartImage.alpha = 0
        updateCacheImagesSizeLabel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startHeartAnimation()
    }
    
    @objc private func startHeartAnimation(){
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.duration = 1.2
        animation.autoreverses = true
        animation.fromValue = 1
        animation.toValue = 0.8
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.repeatCount = .infinity
        heartImage.layer.add(animation, forKey: "beating animation")
        UIView.animate(withDuration: 0.65) {
            self.heartImage.alpha = 1
        }
    }
    
    private func showClearFavoritesAVController() {
        let avc = UIAlertController(title: nil , message: "Do you really want to clear favorites?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel , handler: nil)
        avc.addAction(cancelAction)
        let confirmAction = UIAlertAction(title: "Delete", style: .destructive) {
            _ in
            self.cacheManager.clearFavorites(completion: nil)
        }
        avc.addAction(confirmAction)
        present(avc, animated: true, completion: nil)
    }
    
    private func showClearCacheAVController() {
        let avc = UIAlertController(title: nil, message: "Do you really want to clear cache?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel , handler: nil)
        avc.addAction(cancelAction)
        let confirmAction = UIAlertAction(title: "Delete", style: .destructive) {
            _ in
            self.cacheManager.clearAllStaticMediaData {
                _ in
                UserDefaults.standard.setValue(0, forKey: UserDefaults.keyForCachedImagesSize)
                DispatchQueue.main.async {
                    self.cacheImagesSizeLabel.text = "0.0 Mb"
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "cacheCleared"), object: nil)
                }
            }
        }
        avc.addAction(confirmAction)
        present(avc, animated: true, completion: nil)
    }
}
