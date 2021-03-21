//
//  GameVideoCell.swift
//  w2p
//
//  Created by vas on 21.03.2021.
//

import UIKit
import AVFoundation
import youtube_ios_player_helper

class GameVideoCompactCell: UICollectionViewCell {
    
    
    
    @IBOutlet weak var videoView: YTPlayerView!
    

    func setup(videoId: String) {
        videoView.load(withVideoId: videoId)
        videoView.delegate = YoutubeViewDelegate()
    }
    
    func startPlaying() {
        
    }
}

class YoutubeViewDelegate: NSObject, YTPlayerViewDelegate {
        
    yt
    
    
    
    
    
}
