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
    var tuner: GameVideoCellTuner?
    var isSetup = false

    override var staticMediaView: UIImageView?{
        thumbView
    }
    
    let avPlayerController = AVPlayerViewController()
    
    var player: AVPlayer? {
        avPlayerController.player
    }
    
    
    @IBOutlet weak var preloadThumb: UIImageView!
    
    
    lazy var thumbView: UIImageView = {
        guard let overlayView = avPlayerController.contentOverlayView else { fatalError("no overlay view") }
        let thumbView = UIImageView()
        thumbView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.addSubview(thumbView)
        thumbView.fixIn(view: overlayView)
        return thumbView
    }()
    
    func setupPlayerController(parentVC: UIViewController) {
        parentVC.addChild(avPlayerController)
        avPlayerController.didMove(toParent: parentVC)
        avPlayerController.allowsPictureInPicturePlayback = false

        if let playerControllerView = avPlayerController.view {
            playerControllerView.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(playerControllerView)
            contentView.bringSubviewToFront(playerControllerView)
            playerControllerView.fixIn(view: contentView)
            playerControllerView.alpha = 0
            
            let tapGR = UITapGestureRecognizer(target: self, action: #selector(playVideo))
            tapGR.allowedPressTypes = [
                NSNumber(value: UIPress.PressType.menu.rawValue)
            ]
            tapGR.cancelsTouchesInView = false
            playerControllerView.addGestureRecognizer(tapGR)

        }
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(audioInterruptionHandler), name: AVAudioSession.interruptionNotification, object:  AVAudioSession.sharedInstance())
        

    }
    
    @objc func playVideo() {
        player?.play()
    }

    @objc func audioInterruptionHandler(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue)
        else {
            return
        }
        if type == .began {
            self.player?.pause()
        }
    }
    
    
    //MARK: FIX
    /*
    override func reload() {
        finishShowingInfoContainer(duration: 0.3) {
            self.loadVideo()
        }
    }
    */

    override func prepareForReuse() {
        super.prepareForReuse()
        preloadThumb.alpha = 0
        avPlayerController.view.alpha = 0
       
        
    }
    
    func pauseVideo() {
        player?.pause()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}



