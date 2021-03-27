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
    var gameRandomizer = GameRandomizer()
    
    @IBOutlet weak var searchBar: UIVisualEffectView!
    @IBOutlet weak var searchFieldBackground: UIView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchField: UITextField!
    
    @IBOutlet weak var randomButton: UIButton!
    
    
    @IBAction private func searchButtonTapped(_ sender: UIButton) {
        FeedbackManager.generateFeedbackForButtonsTapped()
        if !self.initialAnimationExecuted {
            self.finishInitialAnimation() {
                self.searchGames(withAnimation: true)
            }
            self.initialAnimationExecuted = true
        } else {
            self.searchGames(withAnimation: true)
        }
    }
    
    @IBAction private func randomTapped(_ sender: UIButton) {
        FeedbackManager.generateFeedbackForButtonsTapped()
        if !self.initialAnimationExecuted {
            self.finishInitialAnimation() {
                self.presentRandomGames()
            }
            self.initialAnimationExecuted = true
        } else {
            presentRandomGames()
        }
    }
    
    private func prepareToLoad() {
        DispatchQueue.main.async {
            self.disableActionButtons()
            self.panGestureRecognizer.isEnabled = false
        }
    }
    
    private func afterLoad() {
        DispatchQueue.main.async {
            self.enableActionButtons()
            if !self.games.isEmpty {
                self.panGestureRecognizer.isEnabled = true
                
            } else {
                self.panGestureRecognizer.isEnabled = false
            }
        }
    }
    
    
    private func presentRandomGames() {
        prepareToLoad()
        gameRandomizer.reset()
        gameApiRequestItem = GameApiRequestItem.formRequestItemForRandomGames()
        afterLoadApiItemAction = {
            self.gameRandomizer.updateApiRequestItemWithNewGames(item: self.gameApiRequestItem!)
        }
        gameRandomizer.updateApiRequestItemWithNewGames(item: gameApiRequestItem!) {
            DispatchQueue.main.async {
                self.refreshGames(withAnimation: true) {
                    success in
                    self.afterLoad()
                }
            }
        }
    }
    
    private func searchGames(withAnimation: Bool) {
        prepareToLoad()
        self.gameApiRequestItem = GameApiRequestItem.formRequestItemForSearching(filter: self.searchFilter, limit: 500)
        afterLoadApiItemAction = {
            self.currentOffset += self.gamesPerRequest
            self.gameApiRequestItem?.offset = self.currentOffset
        }
        super.refreshGames(withAnimation: withAnimation) {
            success in
            self.afterLoad()
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
    
    private func disableActionButtons() {
        self.searchButton.isUserInteractionEnabled = false
        self.randomButton.isUserInteractionEnabled = true
        UIView.animate(withDuration: 0.5, delay: 0, options: .beginFromCurrentState) {
            self.searchButton.alpha = 0.4
            self.randomButton.alpha = 0.4
        }
    }
    
    private func enableActionButtons() {
        UIView.animate(withDuration: 0.3) {
            self.searchButton.alpha = 1
            self.randomButton.alpha = 1
        } completion: { _ in
            self.searchButton.isUserInteractionEnabled = true
            self.randomButton.isUserInteractionEnabled = true
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
        disableActionButtons()
        UIView.animate(withDuration: 0.8, delay: 0, options: [.curveEaseOut]) {
            UIView.animate(withDuration: 0.3, delay: 0.7) {
                self.infoLabel.alpha = 1
            }
            self.infoImageView.transform = .identity
        } completion: { _ in
            self.enableActionButtons()
        }
    }
    
    func finishInitialAnimation(completion: (()->Void)? = nil) {
        UIView.animate(withDuration: 0.45) {
            self.infoLabel.alpha = 0
            self.infoImageView.transform = CGAffineTransform(translationX: 0, y: -((self.view.frame.height / 2) + self.infoImageView.frame.height))
        } completion: { _ in
            super.resetInfoContainer()
            completion?()
        }
    }
}



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
