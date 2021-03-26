//
//  NewGamesController.swift
//  w2p
//
//  Created by vas on 19.03.2021.
//

import UIKit

class NewGamesController: GameBrowserController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupRequestItem()
        setupGestureRecognizers()
    }
    
    var panGestureRecognizer: UIPanGestureRecognizer!
    var initialLoad = true
    
    
    @IBOutlet weak var reloadButton: CustomButton!
    @IBAction func reloadTapped(_ sender: CustomButton) {
        reloadGames()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if initialLoad {
            reloadGames()
        }
        setupControls()
    }
    
    private func reloadGames() {
        panGestureRecognizer.isEnabled = false
        disableReloadButton()
        refreshGames(withAnimation: true) {
            success in
            
            if success, !self.games.isEmpty {
                self.panGestureRecognizer.isEnabled = true
            }
            self.enableReloadButton()

        }
        initialLoad = false
    }
    
    private func disableReloadButton() {
        reloadButton.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.2, delay:  0, options: .beginFromCurrentState) {
            self.reloadButton.alpha = 0.5
        }
    }
    
    private func enableReloadButton() {
        UIView.animate(withDuration: 0.2, delay: 0, options: .beginFromCurrentState) {
            self.reloadButton.alpha = 1
        } completion: { _ in
            self.reloadButton.isUserInteractionEnabled = true
        }
    }
    
    private func setupControls() {
        reloadButton.layer.cornerRadius = reloadButton.frame.height / 2
    }
    
    
    private func setupGestureRecognizers(){
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(pan))
        panGestureRecognizer.delegate = self
        collectionView.addGestureRecognizer(panGestureRecognizer)
        panGestureRecognizer.isEnabled = false
    }
    
    @objc func pan(sender: UIPanGestureRecognizer){
        switch sender.state {
        case .ended:
            let yVelocity = sender.velocity(in: view).y
            if yVelocity > 1000 {
                if self.reloadButton.isHidden {
                    self.reloadButton.isHidden = false
                    UIView.animate(withDuration: 0.3,delay: 0,options: [.beginFromCurrentState], animations: {
                        self.reloadButton.alpha = 1
                    })
                }
            } else if yVelocity < -500 {
                if !self.reloadButton.isHidden{
                    UIView.animate(withDuration: 0.3,delay: 0,options: [.beginFromCurrentState], animations: {
                        self.reloadButton.alpha = 0
                    }, completion: {
                        _ in
                        self.reloadButton.isHidden = true
                    })
                }
            }
        default:
            return
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.contentOffset.y <= 0{
            self.reloadButton.isHidden = false
            UIView.animate(withDuration: 0.3, animations: {
                self.reloadButton.alpha = 1
            })
        }
    }
    
    
    override var headerHeight: CGFloat? {
        70
    }
    
    
    
    override func setup(header: HeaderWaterfallLayoutView) {
        header.label.text = "New Games"
    }
    
    
    private func setupRequestItem() {
        gameApiRequestItem = GameApiRequestItem.formRequestItemForNewAvailableGames()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "detailed":
            let destinationVc = segue.destination as! DetailedViewController
            destinationVc.game = (sender as? Game)
        default:
            return
        }
    }
}

extension NewGamesController: UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}
