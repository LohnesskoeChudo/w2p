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
    @IBOutlet weak var genreStack: UIStackView!
    
    @IBOutlet weak var themeStack: UIStackView!
    
    @IBOutlet weak var platformStack: UIStackView!
    
    override func viewDidLoad() {
        setupNameLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        layoutCover()
        setupCover()
        setupGameAttributesViews()
    }
    
    func setupNameLabel(){
        if let gameName = game.name{
            nameLabel.text = gameName
            nameLabel.font = UIFont.boldSystemFont(ofSize: 25)
        } else {
            nameLabel.isHidden = true
        }
    }
    
    func setupGameAttributesViews(){
        if let genres = game.genres, !genres.isEmpty{
            genreStack.superview!.isHidden = false
            for genre in genres{
                let genreView = GameAttributeView()
                genreView.setup(text: genre.name, color: UIColor.red.withAlphaComponent(0.2))
                genreStack.addArrangedSubview(genreView)
            }
        }
        if let themes = game.themes, !themes.isEmpty{
            themeStack.superview!.isHidden = false
            for theme in themes{
                let themeView = GameAttributeView()
                themeView.setup(text: theme.name, color: UIColor.blue.withAlphaComponent(0.2))
                themeStack.addArrangedSubview(themeView)
            }
        }
        if let platforms = game.platforms, !platforms.isEmpty{
            platformStack.superview!.isHidden = false
            for platform in platforms{
                let platformView = GameAttributeView()
                platformView.setup(text: platform.name, color: UIColor.green.withAlphaComponent(0.2))
                platformStack.addArrangedSubview(platformView)
            }
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
        
        coverView.layer.borderWidth = 3
        coverView.layer.borderColor = UIColor.black.cgColor
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
