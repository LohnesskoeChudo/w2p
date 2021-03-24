//
//  GameBrowserViewController.swift
//  w2p
//
//  Created by vas on 26.02.2021.
//

import UIKit
class SimilarGamesController : GameBrowserController{
    
    var externalGame: Game!
    var category: BrowserGameCategory!
    var panGestureRecognizer: UIPanGestureRecognizer!
    
    override var upperSpacing: CGFloat {
        upperBar.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
    }

    @IBAction func backButtonPressed(_ sender: CustomButton) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func refresh(_ sender: CustomButton) {
        self.refreshGames(withAnimation: true)
    }
    
    private func refreshGames(withAnimation: Bool) {
        self.disableRefreshButton()
        panGestureRecognizer.isEnabled = false
        super.refreshGames(withAnimation: true) {
            success in
            if !self.games.isEmpty {
                self.panGestureRecognizer.isEnabled = true
            } else {
                self.panGestureRecognizer.isEnabled = false
            }
            self.enableRefreshButton()
        }
    }
    
    @IBOutlet weak var refreshButton: CustomButton!
    
    private func disableRefreshButton() {
        refreshButton.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.3) {
            self.refreshButton.alpha = 0.5
        }
    }
    
    private func enableRefreshButton() {
        UIView.animate(withDuration: 0.3) {
            self.refreshButton.alpha = 1
        } completion: { _ in
            self.refreshButton.isUserInteractionEnabled = true
        }
    }
    
    @IBOutlet weak var upperBar: UIView!
    
    var needToUpdateGames = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGestureRecognizers()
        setupApiRequestItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if needToUpdateGames {
            self.refreshGames(withAnimation: false)
            needToUpdateGames = false
        }
    }
    
    
    private func setupApiRequestItem() {
        if category == .similarGames{
            gameApiRequestItem = GameApiRequestItem.formRequestItemForSimilarGames(with: externalGame)
        } else if category == .franchiseGames{
            gameApiRequestItem = GameApiRequestItem.formRequestItemForSpecificGames(gamesIds: externalGame.franchise?.games ?? [])
        } else {
            gameApiRequestItem = GameApiRequestItem.formRequestItemForSpecificGames(gamesIds: externalGame.collection?.games ?? [])
        }
    }
    



    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "detailed":
            let game = sender as! Game
            let detailedVC = segue.destination as! DetailedViewController
            detailedVC.game = game
        default:
            return
        }
    }
    
    private func setupGestureRecognizers(){
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(pan))
        panGestureRecognizer.delegate = self
        collectionView.addGestureRecognizer(panGestureRecognizer)

    }
    
    @objc func pan(sender: UIPanGestureRecognizer){
        switch sender.state {
        case .ended:
            let yVelocity = sender.velocity(in: view).y
            if yVelocity > 1000 {
                if self.upperBar.isHidden {
                    self.upperBar.isHidden = false
                    UIView.animate(withDuration: 0.3, animations: {
                        self.upperBar.alpha = 0.9
                    })
                }
            } else if yVelocity < -500 {
                if !self.upperBar.isHidden{
                    UIView.animate(withDuration: 0.3, animations: {
                        self.upperBar.alpha = 0
                    }, completion: {
                        _ in
                        self.upperBar.isHidden = true
                    })
                }
            }
        default:
            return
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 0{
            upperBar.isHidden = false
            UIView.animate(withDuration: 0.3, animations: {
                self.upperBar.alpha = 0.9
            })
        }
    }
    
}


extension SimilarGamesController: UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}
