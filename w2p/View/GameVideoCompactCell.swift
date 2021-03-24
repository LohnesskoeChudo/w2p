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

    var videoIsReadyObservationToken: NSKeyValueObservation?
    
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
            print("player view inserted")
            playerControllerView.fixIn(view: contentView)
            playerControllerView.alpha = 0
        }
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(audioInterruptionHandler), name: AVAudioSession.interruptionNotification, object:  AVAudioSession.sharedInstance())
        
        videoIsReadyObservationToken = avPlayerController.observe(\.isReadyForDisplay, options: [.new]) { [weak self]
            
            avController, change in
            print("work")
            
            if change.newValue == true {
                print("video is ready")
            }
            
        }
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
        print("cell deinit")
        NotificationCenter.default.removeObserver(self)
        videoIsReadyObservationToken?.invalidate()
    }
}
