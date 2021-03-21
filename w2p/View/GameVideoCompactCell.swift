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
    
    
    
    var videoId: String?
    let playerVars: [AnyHashable: Any] = [
        "playsinline" : 1,
        "rel" : 0,
        "modestbranding" : 1,
        "fs" : 0,
        "loop" : 1
    
    ]

    func setup(videoId: String) {
        self.videoId = videoId
        videoView.webView?.configuration
        videoView.delegate = self
        videoView.load(withVideoId: videoId, playerVars: playerVars)
        

    }
    
    func startPlaying() {
        
    }
}

extension GameVideoCompactCell: YTPlayerViewDelegate {

    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        if state == .ended{
            if let videoId = videoId {
                
                playerView.load(withVideoId: videoId, playerVars: playerVars)
            }
        }
    }
}


extension GameVideoCompactCell: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        let config = WKWebViewConfiguration()
        config.allowsAirPlayForMediaPlayback = false
        config.allowsPictureInPictureMediaPlayback = false
        let webview = WKWebView(frame: .zero, configuration: config)
        return webview
    }
}

    
    
    
