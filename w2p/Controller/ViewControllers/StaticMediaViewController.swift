//
//  StaticMediaViewController.swift
//  w2p
//
//  Created by vas on 27.03.2021.
//

import UIKit

class StaticMediaViewController: UIViewController {
    
    var staticMedia: [MediaDownloadable]!
    var currentPage: Int!
    
    private let mediaDispatcher = GameMediaDispatcher()


    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        OrientationResolver.allowToChangeOrientation = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        OrientationResolver.allowToChangeOrientation = false
    }
    
}


extension StaticMediaViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        staticMedia.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "staticMediaCell", for: indexPath) as! StaticMediaCell
        
        let media = staticMedia[indexPath.item]
        
        setup(cell: cell, with: media)
        cell.reloadAction = { [weak self, cell, media] in
            self?.setup(cell: cell, with: media)
        }

        return cell
        
    }
    

    private func setup(cell: StaticMediaCell, with media: MediaDownloadable) {
        cell.id = UUID()
        cell.startLoadingAnimation()
        cell.isLoading = true
        let initialId = cell.id
        mediaDispatcher.fetchPreparedToSetStaticMedia(with: media, targetWidth: view.frame.width, sizeKey: .Ss1280X720) {
            image, error in
            
            if initialId != cell.id {return}
            cell.isLoading = false
            
            cell.finishShowingInfoContainer(duration: 0.3) {
                
                if let image = image {
                    cell.setupStaticMediaView(image: image)
                } else {
                    cell.showConnectionProblemMessage(duration: 0.3)
                }
            }
        }
    }
}

extension StaticMediaViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        view.frame.size
    }
}
