//
//  ViewController.swift
//  w2p
//
//  Created by vas on 13.02.2021.
//

import UIKit
class SearchViewController: GameBrowserController{
    
    
    
    
    var panGestureRecognizer: UIPanGestureRecognizer!
    override var upperSpacing: CGFloat { searchBar.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height + 10 }
    var initialAnimationExecuted = false
    

    // MARK: - Outlets
    
    @IBOutlet weak var searchBar: UIVisualEffectView!
    @IBOutlet weak var searchFieldBackground: UIView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchField: UITextField!
    
    // MARK: - Actions
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        FeedbackManager.generateFeedbackForButtonsTapped()
        
        let gamesWereEmpty = games.isEmpty
            
        disableSearchButton()
        games = []
        gamesSource.clear()
        currentOffset = 0
        panGestureRecognizer.isEnabled = false
        
        UIView.transition(with: collectionView, duration: gamesWereEmpty ? 0 : 0.3, options: .transitionCrossDissolve) {

            let wfInvalidationContext = WFLayoutInvalidationContext()
            wfInvalidationContext.action = .rebuild
            self.collectionView.collectionViewLayout.invalidateLayout(with: wfInvalidationContext)

        } completion:  { _ in
            
            var action = {
                self.collectionView.contentOffset = .zero
                self.gameApiRequestItem = GameApiRequestItem.formRequestItemForSearching(filter: self.searchFilter, limit: 500)
                self.loadGames(withAnimation: true) { _ in
                    if !self.games.isEmpty {
                        self.panGestureRecognizer.isEnabled = true
                        
                    } else {
                        self.panGestureRecognizer.isEnabled = false
                    }
                    self.enableSearchButton()
                    self.currentOffset += self.gamesPerRequest
                }
            }
            
            if !self.initialAnimationExecuted {
                self.finishInitialAnimation() {
                    action()
                }
                self.initialAnimationExecuted = true
            } else {
                action()
            }

        }
    }
    
    @IBAction func filterTapped(_ sender: UIButton) {
        FeedbackManager.generateFeedbackForButtonsTapped()
    }
    
    @IBAction func searchFieldEditingChanged(_ sender: UITextField) {
        searchFilter.searchString = sender.text
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGestureRecognizers()
    }
    
    var initialCall = true
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupSearchBar()
        if initialCall {
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if initialCall {
            
            prepareForInitialAnimation()
            performInitialAnimation()
            initialCall = false
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "filter":
            let navigationVC = segue.destination as! UINavigationController
            let filterVC = navigationVC.viewControllers.first as! FilterViewController
            filterVC.filter = searchFilter
            
        case "detailed":
            let game = sender as! Game
            let detailedVC = segue.destination as! DetailedViewController
            detailedVC.game = game

        default:
            return
        }
    }
    
    private func disableSearchButton() {
        self.searchButton.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.5, delay: 0, options: .beginFromCurrentState) {
            self.searchButton.alpha = 0.4
        }
    }
    
    private func enableSearchButton() {
        UIView.animate(withDuration: 0.3) {
            self.searchButton.alpha = 1
        } completion: { _ in
            self.searchButton.isUserInteractionEnabled = true
        }
    }

    private func setupSearchBar(){
        searchBar.layer.cornerRadius = searchBar.frame.height / 2
        searchField.delegate = self
        searchFieldBackground.layer.cornerRadius = searchFieldBackground.frame.height / 2
        searchFieldBackground.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
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
                if self.searchBar.isHidden {
                    self.searchBar.isHidden = false
                    UIView.animate(withDuration: 0.3,delay: 0,options: [.beginFromCurrentState], animations: {
                        self.searchBar.alpha = 1
                    })
                }
            } else if yVelocity < -500 {
                if !self.searchBar.isHidden{
                    UIView.animate(withDuration: 0.3,delay: 0,options: [.beginFromCurrentState], animations: {
                        self.searchBar.alpha = 0
                    }, completion: {
                        _ in
                        self.searchBar.isHidden = true
                    })
                }
            }
        default:
            return
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.contentOffset.y <= 0{
            self.searchBar.isHidden = false
            UIView.animate(withDuration: 0.3, animations: {
                self.searchBar.alpha = 1
            })
        }
    }
    
    private func prepareForInitialAnimation() {
        infoContainer.isHidden = false
        infoContainer.alpha = 1
        infoLabel.alpha = 0
        infoLabel.numberOfLines = 0
        infoLabel.text = "Lets find some cool games!\n\nApply filter and search by any keyword or get a random set of games."
        infoImageView.image = UIImage(named: "rocket")
        infoImageView.transform = CGAffineTransform(translationX: 0, y: (self.view.frame.height / 2 + infoImageView.frame.height))
    }
    

    
    func performInitialAnimation(completion: (() -> Void)? = nil) {
        disableSearchButton()
        UIView.animate(withDuration: 0.8, delay: 0, options: [.curveEaseOut]) {
            UIView.animate(withDuration: 0.3, delay: 0.7) {
                self.infoLabel.alpha = 1
            }
            self.infoImageView.transform = .identity
        } completion: { _ in
            self.enableSearchButton()
        }
    }
    
    func finishInitialAnimation(completion: (()->Void)? = nil) {
        UIView.animate(withDuration: 0.45) {
            self.infoLabel.alpha = 0
            self.infoImageView.transform = CGAffineTransform(translationX: 0, y: -((self.view.frame.height / 2) + self.infoImageView.frame.height))
        } completion: { _ in
            self.resetInfoContainer()
            completion?()
        }
        
        
    }
    
    private func resetInfoContainer() {
        infoContainer.isHidden = true
        infoLabel.alpha = 1
        infoImageView.alpha = 1
        infoImageView.transform = .identity
    }
    

}

// MARK: - Delegates

extension SearchViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension SearchViewController: UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}
