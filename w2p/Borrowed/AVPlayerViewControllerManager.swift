//
//  AVPlayerViewControllerManager.swift
//  XCDYouTubeKit iOS Demo
//
//  Created by Soneé John on 10/29/19.
//  Copyright © 2019 Cédric Luthi. All rights reserved.
//
import AVKit
import Foundation
import MediaPlayer
import XCDYouTubeKit


extension UIViewController {
    func topMostViewController() -> UIViewController {
        if self.presentedViewController == nil {
            return self
        }
        if let navigation = self.presentedViewController as? UINavigationController {
            return navigation.visibleViewController!.topMostViewController()
        }
        if let tab = self.presentedViewController as? UITabBarController {
            if let selectedTab = tab.selectedViewController {
                return selectedTab.topMostViewController()
            }
            return tab.topMostViewController()
        }
        return self.presentedViewController!.topMostViewController()
    }
}


extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}


@objcMembers class AVPlayerViewControllerManager: NSObject {

    public var lowQualityMode = false
    public dynamic var duration: Float = 0

    
    public var video: XCDYouTubeVideo? {
        didSet {
            guard let controller = controller else {fatalError("no controller")}
            guard let video = video else { return }
            guard self.lowQualityMode == false else {
                
                guard let streamURL = video.streamURLs[XCDYouTubeVideoQualityHTTPLiveStreaming] ?? video.streamURLs[XCDYouTubeVideoQuality.medium360.rawValue] ?? video.streamURLs[XCDYouTubeVideoQuality.small240.rawValue] else { fatalError("No stream URL") }

                self.player = AVPlayer(url: streamURL)
                controller.player = self.player
                return
                
            }
            let streamURL = video.streamURL
            self.player = AVPlayer(url: streamURL!)
            controller.player = self.player
        }
    }

    var player: AVPlayer?
    weak var controller: AVPlayerViewController?

    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(audioInterruptionHandler), name: AVAudioSession.interruptionNotification, object:  AVAudioSession.sharedInstance())

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
    
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
