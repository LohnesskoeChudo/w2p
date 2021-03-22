//
//  GameVideoCell.swift
//  w2p
//
//  Created by vas on 21.03.2021.
//

import UIKit
import AVFoundation
import XCDYouTubeKit



class GameVideoCompactCell: UICollectionViewCell {

    
    @IBOutlet weak var videoView: VideoCompactView!

    
    private var player: AVPlayer? {
        get {
            videoView.player
        }
        set {
            videoView.player = newValue
        }
    }
    
    var videoId: String?

    func setup(videoId: String) {
        self.videoId = videoId
        XCDYouTubeClient.default().getVideoWithIdentifier(videoId) { [self]
            (video: XCDYouTubeVideo?, error: Error?) in
            YoutubePlayerManager.shared.video = video
            self.player = YoutubePlayerManager.shared.player
            self.player?.play()
        }
    }
    
    func startPlaying() {
        
    }
}

