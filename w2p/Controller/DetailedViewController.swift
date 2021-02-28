//
//  DetailedViewController.swift
//  w2p
//
//  Created by vas on 13.02.2021.
//

import UIKit

class DetailedViewController: UIViewController{
    
    var game: Game!
    var mediaDispatcher = GameMediaDispatcher()
    var imageBlurrer = ImageBlurrer()
    
    @IBOutlet weak var coverView: UIImageView!
    @IBOutlet weak var blurredBackground: UIImageView!
    @IBOutlet weak var coverWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var coverHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var genreThemeStack: UIStackView!
    @IBOutlet weak var gameModeStack: UIStackView!
    @IBOutlet weak var platformStack: UIStackView!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var storylineLabel: UILabel!
    @IBOutlet weak var attributesContainer: UIView!
    @IBAction func similarGamesTapped(_ sender: CommonButton) {
        performSegue(withIdentifier: "browser", sender: BrowserGameCategory.similarGames)
    }
    
    @IBAction func franchiseGamesTapped(_ sender: CommonButton) {
        performSegue(withIdentifier: "browser", sender: BrowserGameCategory.franchiseGames)
    }
    
    @IBAction func collectionGamesTapped(_ sender: CommonButton) {
        performSegue(withIdentifier: "browser", sender: BrowserGameCategory.collectionGames)
    }
    
    @IBOutlet weak var similarGamesButton: CommonButton!
    @IBOutlet weak var franchiseGamesButton: CommonButton!
    @IBOutlet weak var collectionGamesButton: CommonButton!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
        case "browser":
            guard let browserVC = segue.destination as? GameBrowserViewController, let gameCategory = sender as? BrowserGameCategory else {return}

            browserVC.externalGame = game
            browserVC.category = gameCategory
        default:
            return
        }
    }
    
    override func viewDidLoad() {
        setupNameLabel()
        setupGameAttributesViews()
        setupCover()
        setupSummaryLabel()
        setupStorylineLabel()
        setupNavigationButtons()
        print(game.firstReleaseDate)
        navigationController?.setNavigationBarHidden(true, animated: false)

        if let gamemodes = game.gameModes{
            for k in gamemodes{
                print(k.name)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        layoutCover()
    }
    
    func setupNavigationButtons(){
        if game.similarGames != nil{
            similarGamesButton.textLabel.text = "Similar games"
        } else {
            similarGamesButton.isHidden = true
        }
        if game.franchise?.games != nil{
            franchiseGamesButton.textLabel.text = "Franchise games"
        } else {
            franchiseGamesButton.isHidden = true
        }
        if game.collection?.games != nil{
            collectionGamesButton.textLabel.text = "Collection games"
        } else {
            collectionGamesButton.isHidden = true
        }
    }
    
    func setupNameLabel(){
        if let gameName = game.name{
            nameLabel.text = gameName
            nameLabel.font = UIFont.boldSystemFont(ofSize: 25)
        } else {
            nameLabel.superview?.isHidden = true
        }
    }
    
    func setupSummaryLabel(){
        if let summary = game.summary{
            summaryLabel.text = summary
        } else {
            summaryLabel.superview?.isHidden = true
        }
    }
    
    func setupStorylineLabel(){
        if let storyline = game.storyline{
            storylineLabel.text = storyline
        } else {
            storylineLabel.superview?.isHidden = true
        }
    }
    
    func setupGameAttributesViews(){
        
        var genresThemesViews = [GameAttributeView]()
        if let genres = game.genres{
            genresThemesViews += genres.map{
                genre in
                let gav = GameAttributeView()
                gav.setup(text: genre.name, color: UIColor.red.withAlphaComponent(0.2))
                return gav
            }
        }
        if let themes = game.themes{
            genresThemesViews += themes.map{
                theme in
                let gav = GameAttributeView()
                gav.setup(text: theme.name, color: UIColor.green.withAlphaComponent(0.2))
                return gav
            }
        }
        if !genresThemesViews.isEmpty{
            for (index, gav) in genresThemesViews.enumerated(){
                genreThemeStack.insertArrangedSubview(gav, at: index + 1)
            }
        } else {
            genreThemeStack.superview?.isHidden = true
        }
        
        
        if let gameModes = game.gameModes, !gameModes.isEmpty{
            gameModeStack.superview!.isHidden = false
            for (index, gameMode) in gameModes.enumerated(){
                let gameModeView = GameAttributeView()
                gameModeView.setup(text: gameMode.name, color: UIColor.blue.withAlphaComponent(0.2))
                gameModeStack.insertArrangedSubview(gameModeView, at: index + 1)
            }
        } else {
            gameModeStack.superview?.isHidden = true
        }
        
        if let platforms = game.platforms, !platforms.isEmpty{
            platformStack.superview!.isHidden = false
            for (index,platform) in platforms.enumerated(){
                let platformView = GameAttributeView()
                platformView.setup(text: platform.name, color: UIColor.purple.withAlphaComponent(0.2))
                platformStack.insertArrangedSubview(platformView, at: index + 1)
            }
        } else {
            platformStack.superview?.isHidden = true
        }
        
        
        if platformStack.superview!.isHidden && genreThemeStack.superview!.isHidden && gameModeStack.superview!.isHidden {
            attributesContainer.isHidden = true
        }
    }
   
    private func setupCover(){
        
        DispatchQueue.global(qos: .userInitiated).async{
            self.mediaDispatcher.fetchCoverFor(game: self.game, cache: true){
                data, error in
                if let data = data, let image = UIImage(data: data){
                    let blurred = self.imageBlurrer.blurImage(with: image, radius: 30)
                    DispatchQueue.main.async {
                        self.coverView.image = image
                        self.blurredBackground.image = blurred
                    }
                }
            }
        }
    }
    
    private func layoutCover(){
        
        let heightPercentage: CGFloat = 0.58

        guard let aspect = game.cover?.aspect else {return}
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

enum BrowserGameCategory {
    case similarGames, franchiseGames, collectionGames
}



