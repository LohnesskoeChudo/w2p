//
//  AVPlayerViewControllerManager.swift
//  w2p
//
//  Created by vas on 21.03.2021.
//

import Foundation
import AVKit
import MediaPlayer
import XCDYouTubeKit



@objcMembers class YoutubePlayerManager: NSObject {
    // MARK: - Public


    public static let shared = YoutubePlayerManager()
    public var lowQualityMode = false
    public dynamic var duration: Float = 0

    public var video: XCDYouTubeVideo? {
        didSet {
            guard let video = video else { return }
            guard self.lowQualityMode == false else {
                guard let streamURL = video.streamURLs[XCDYouTubeVideoQualityHTTPLiveStreaming] ?? video.streamURLs[XCDYouTubeVideoQuality.medium360.rawValue] ?? video.streamURLs[XCDYouTubeVideoQuality.small240.rawValue] else { fatalError("No stream URL") }

                self.player = AVPlayer(url: streamURL)
                return
            }
            let streamURL = video.streamURL
            self.player = AVPlayer(url: streamURL!)
        }
    }


    public var player: AVPlayer? {
        didSet {
            if let playerRateObserverToken = playerRateObserverToken {
                playerRateObserverToken.invalidate()
                self.playerRateObserverToken = nil
            }

            self.playerRateObserverToken = self.player?.observe(\.rate, changeHandler: { _, _ in
                self.updatePlaybackRateMetadata()
            })
            
            guard let video = self.video else { return }
            if let token = timeObserverToken {
                oldValue?.removeTimeObserver(token)
                self.timeObserverToken = nil
            }
            self.setupRemoteTransportControls()
            self.updateGeneralMetadata(video: video)
            self.updatePlaybackDuration()
        }
    }

    override init() {
        super.init()

        NotificationCenter.default.addObserver(forName: AVAudioSession.interruptionNotification, object: AVAudioSession.sharedInstance(), queue: .main) { notification in

            guard let userInfo = notification.userInfo,
                  let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
                  let type = AVAudioSession.InterruptionType(rawValue: typeValue)
            else {
                return
            }

            if type == .began {
                self.player?.pause()
            } else if type == .ended {
                guard (try? AVAudioSession.sharedInstance().setActive(true)) != nil else { return }
                guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                guard options.contains(.shouldResume) else { return }
                self.player?.play()
            }
        }
    }

    // MARK: Private

    fileprivate var playerRateObserverToken: NSKeyValueObservation?
    fileprivate var timeObserverToken: Any?
    fileprivate let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
    
    fileprivate func setupRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.addTarget { [unowned self] _ in
            if self.player?.rate == 0.0 {
                self.player?.play()
                return .success
            }
            return .commandFailed
        }


        commandCenter.pauseCommand.addTarget { _ in
            if self.player?.rate == 1.0 {
                self.player?.pause()
                return .success
            }
            return .commandFailed
        }
    }
    
    fileprivate func updateGeneralMetadata(video: XCDYouTubeVideo) {
        guard self.player?.currentItem != nil else {
            self.nowPlayingInfoCenter.nowPlayingInfo = nil
            return
        }
        
        var nowPlayingInfo = self.nowPlayingInfoCenter.nowPlayingInfo ?? [String: Any]()
        let title = video.title

        if let thumbnailURL = video.thumbnailURLs {
            URLSession.shared.dataTask(with: thumbnailURL[0]) { data, _, error in
                guard error == nil else { return }
                guard data != nil else { return }
                guard let image = UIImage(data: data!) else { return }

                let artwork = MPMediaItemArtwork(image: image)
                nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
                self.nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
            }.resume()
        }
        
        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        self.nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
    }

    fileprivate func updatePlaybackDuration() {
        let interval = CMTime(seconds: 1.0, preferredTimescale: CMTimeScale(NSEC_PER_SEC))

        timeObserverToken = self.player?.addPeriodicTimeObserver(forInterval: interval, queue: .main, using: { [weak self] _ in
            guard let player = self?.player else { return }
            guard player.currentItem != nil else { return }

            var nowPlayingInfo = self!.nowPlayingInfoCenter.nowPlayingInfo ?? [String: Any]()
            self!.duration = Float(CMTimeGetSeconds(player.currentItem!.duration))
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = self!.duration
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(player.currentItem!.currentTime())
            self!.nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
        })
    }

    fileprivate func updatePlaybackRateMetadata() {
        guard self.player?.currentItem != nil else {
            self.duration = 0
            self.nowPlayingInfoCenter.nowPlayingInfo = nil
            return
        }
        
        var nowPlayingInfo = self.nowPlayingInfoCenter.nowPlayingInfo ?? [String: Any]()
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = self.player!.rate
        nowPlayingInfo[MPNowPlayingInfoPropertyDefaultPlaybackRate] = self.player!.rate
    }
}
