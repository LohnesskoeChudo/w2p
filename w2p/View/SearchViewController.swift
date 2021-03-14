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
   

    // MARK: - Outlets
    
    @IBOutlet weak var searchBar: UIVisualEffectView!
    @IBOutlet weak var searchFieldBackground: UIView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchField: UITextField!
    
    // MARK: - Actions
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        FeedbackManager.generateFeedbackForButtonsTapped()
        games = []
        gamesSource.clear()
        currentOffset = 0
        panGestureRecognizer.isEnabled = false
        
        UIView.transition(with: collectionView, duration: 0.3, options: .transitionCrossDissolve) {

            let wfInvalidationContext = WFLayoutInvalidationContext()
            wfInvalidationContext.action = .rebuild
            self.collectionView.collectionViewLayout.invalidateLayout(with: wfInvalidationContext)
            
        } completion:  { _ in
            self.collectionView.contentOffset = .zero
            self.gameApiRequestItem = GameApiRequestItem.formRequestItemForSearching(filter: self.searchFilter, limit: 500)
            self.loadGames(withAnimation: true) { _ in
                if !self.games.isEmpty {
                    self.panGestureRecognizer.isEnabled = true
                    
                } else {
                    self.panGestureRecognizer.isEnabled = false
                }
            }
            self.currentOffset += self.gamesPerRequest
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupSearchBar()
        setupButtons()
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

    private func setupSearchBar(){
        searchBar.layer.cornerRadius = searchBar.frame.height / 2
        searchField.delegate = self
        searchFieldBackground.layer.cornerRadius = searchFieldBackground.frame.height / 2
        searchFieldBackground.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
    }
    
    private func setupButtons(){
        searchButton.adjustsImageWhenHighlighted = true
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
