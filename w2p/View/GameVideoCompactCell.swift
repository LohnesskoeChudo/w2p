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



class GameVideoCompactCell: CompactMediaCell {

    var videoId: String?
    let playerVCManager = AVPlayerViewControllerManager()
    var playerView: UIView?
    var isSetup = false
    
    override var staticMediaView: UIImageView?{
        get {
            playerVCManager.staticMediaContent
        }
    }
    
    func setup(parentVC: UIViewController) {
        playerView =  playerVCManager.setupVideoStack(parentVC: parentVC, fixIn: contentView)
        playerView?.alpha = 0
    }
    
    
    override func reload() {
        finishShowingInfoContainer(duration: 0.3) {
            self.loadVideo()
        }
    }
    
    func loadVideo() {
        guard let videoId = self.videoId else { return }
        let initialId = self.id
        isLoading = true
        startLoadingAnimation()
        playerVCManager.loadVideo(id: videoId) { success in
            DispatchQueue.main.async {
                if initialId == self.id {
                    if success {
                        self.showPlayerView()
                    } else {
                        self.finishShowingInfoContainer(duration: 0.3) {
                            

                            self.showConnectionProblemMessage(duration: 0.3)
                        }
                    }
                }
                self.isLoading = false
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        playerView?.alpha = 0
        
    }
    
    func showPlayerView() {
        UIView.animate(withDuration: 0.3) {
            self.playerView?.alpha = 1
        } completion: { _ in
            self.finishShowingInfoContainer(duration: 0)
        }
    }
    

    func pauseVideo() {
        playerVCManager.player?.pause()
    }
    

    
    deinit {
        print("cell deinit")
    }
}
