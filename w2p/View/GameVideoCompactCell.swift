//
//  GameVideoCell.swift
//  w2p
//
//  Created by vas on 21.03.2021.
//

import UIKit
import AVFoundation
import AVKit
import XCDYouTubeKit



class GameVideoCompactCell: UICollectionViewCell {

    var videoId: String?
    
    let playerVCManager = AVPlayerViewControllerManager()

    func setup(videoId: String) {
        self.videoId = videoId
        if playerVCManager.video == nil {
            XCDYouTubeClient.default().getVideoWithIdentifier(videoId) { [weak self]
                (video: XCDYouTubeVideo?, error: Error?) in
                if let video = video{
                    self?.setupChildPlayerVCifNeeded()
                    self?.playerVCManager.video = video
                }
            }
        }
    }
    
    func pauseVideo() {
        playerVCManager.player?.pause()
    }
    
    private func setupChildPlayerVCifNeeded() {
        if playerVCManager.controller == nil {
            guard let parentVC = parentViewController else {return}
            let playerVC = AVPlayerViewController()
            playerVCManager.controller = playerVC
            parentVC.addChild(playerVC)
            playerVC.didMove(toParent: parentVC)
            if let view = playerVC.view {
                view.translatesAutoresizingMaskIntoConstraints = false
                contentView.addSubview(view)
                view.fixIn(view: contentView)
            }
        }
    }
    
    deinit {
        print("cell deinit")
    }
}

