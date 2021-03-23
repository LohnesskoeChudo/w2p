import AVKit
import Foundation
import XCDYouTubeKit


class AVPlayerViewControllerManager: NSObject {

    var lowQualityMode = false
    static var imageLoader = ImageLoader()
    
    var video: XCDYouTubeVideo? {
        didSet {
            guard let controller = controller else {fatalError("no controller")}
            guard let video = video else { return }
            guard self.lowQualityMode == false else {
                
                guard let streamURL = video.streamURLs[XCDYouTubeVideoQualityHTTPLiveStreaming] ?? video.streamURLs[XCDYouTubeVideoQuality.HD720] ?? video.streamURLs[XCDYouTubeVideoQuality.medium360.rawValue] ?? video.streamURLs[XCDYouTubeVideoQuality.small240.rawValue] else { fatalError("No stream URL") }

                self.player = AVPlayer(url: streamURL)
                controller.player = self.player
                return
                
            }
            let streamURL = video.streamURL
            self.player = AVPlayer(url: streamURL!)
            controller.player = self.player
        }
    }
    
    var staticMediaContent: UIImageView?

    var player: AVPlayer?
    
    
    weak var controller: AVPlayerViewController? {
        didSet {
            guard let controller = controller, let overlay = controller.contentOverlayView else {return}
            
            staticMediaContent = UIImageView()
            staticMediaContent!.translatesAutoresizingMaskIntoConstraints = false
            overlay.addSubview(staticMediaContent!)
            staticMediaContent!.fixIn(view: overlay)
        }
    }
    
    
    func setupVideoStack(parentVC: UIViewController, fixIn view: UIView) -> UIView? {
        self.setupControllerIfNeeded(parentController: parentVC, targetView: view)
        return controller?.view
    }
    
    func loadVideo(id: String, thumbLoadedCompletion: ((_ success: Bool)->Void)? = nil, videoIsReadyCompletion: ((_ success: Bool)->Void)? = nil) {
        XCDYouTubeClient.default().getVideoWithIdentifier(id) {
            (video: XCDYouTubeVideo?, error: Error?) in
            if let video = video{
                self.video = video
                self.loadThumbnail(completion: thumbLoadedCompletion)
                
                
                
                
            } else {
                thumbLoadedCompletion?(false)
                videoIsReadyCompletion?(false)
            }
        }
    }
    
    
    private func setupControllerIfNeeded(parentController: UIViewController, targetView: UIView) {
        if controller == nil {
            let playerController = AVPlayerViewController()
            controller = playerController
            parentController.addChild(playerController)
            playerController.didMove(toParent: parentController)
            if let view = playerController.view {
                view.translatesAutoresizingMaskIntoConstraints = false
                targetView.addSubview(view)
                view.fixIn(view: targetView)
            }
        }
    }
    
    
    func loadThumbnail(completion: ((_ success: Bool) -> Void)? = nil) {
        
        if let thumbUrls = video?.thumbnailURLs, !thumbUrls.isEmpty {
            let url = thumbUrls.last!
            
            var request = URLRequest(url: url)
            
            //request.cachePolicy = URLRequest.CachePolicy.returnCacheDataElseLoad

            Self.imageLoader.load(with: request) { image, error in
                
                if let image = image {
                    DispatchQueue.main.async {
                        self.staticMediaContent?.image = image
                    }
                    completion?(true)
                } else {
                    completion?(false)
                }
            }
        } else {
            completion?(false)
        }
    }
    

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
