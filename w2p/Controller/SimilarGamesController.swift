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
    override var upperSpacing: CGFloat {
        upperBar.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
    }
    
    @IBAction func backButtonPressed(_ sender: CustomButton) {
        navigationController?.popViewController(animated: true)
    }
    @IBOutlet weak var upperBar: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGestureRecognizers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        let request: URLRequest

        if category == .similarGames{
            request = RequestFormer.shared.requestForSimilarGames(for: externalGame)
        } else if category == .franchiseGames{
            request = RequestFormer.shared.formRequestForSpecificGames(externalGame.franchise?.games ?? [])
        } else {
            request = RequestFormer.shared.formRequestForSpecificGames(externalGame.collection?.games ?? [])
        }
        
        loadGames(request: request, withAnimation: true)
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
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(pan))
        panRecognizer.delegate = self
        collectionView.addGestureRecognizer(panRecognizer)

    }
    
    @objc func pan(sender: UIPanGestureRecognizer){
        switch sender.state {
        case .ended:
            let yVelocity = sender.velocity(in: view).y
            print(yVelocity)
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

// MARK: - Delegates

extension SimilarGamesController: UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}
