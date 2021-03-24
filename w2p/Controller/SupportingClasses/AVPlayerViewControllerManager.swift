import AVKit
import Foundation
import XCDYouTubeKit


class GameVideoCellTuner: NSObject {
    
    static var imageLoader = ImageLoader()
    
    weak var cell: GameVideoCompactCell?
    var videoId: String
    var video: XCDYouTubeVideo?
    var initialId: UUID?

    init(cell: GameVideoCompactCell, videoId: String, parentVC: UIViewController) {
        cell.id = UUID()
        self.initialId = cell.id
        self.videoId = videoId
        self.cell = cell
        if self.cell?.isSetup == false {
            self.cell?.setupPlayerController(parentVC: parentVC)
            self.cell?.isSetup = true
        }
    }
    
    func setup() {
        cell?.startLoadingAnimation()
        getYTvideo(){ success in
            DispatchQueue.global(qos: .userInitiated).async {
                if success {
                    guard let video = self.video else { return }
                    
                    
                    DispatchQueue.main.async {
                        self.cell?.avPlayerController.player = self.player(for: video)
                    }
                    
                    
                    self.loadThumbnail()
                    
                    
                } else {
                    
                }
            }
        }
    }
    
    func getYTvideo(completion: ((_ succes: Bool)->Void)? = nil) {
        XCDYouTubeClient.default().getVideoWithIdentifier(videoId) {
            video, error in
            
            DispatchQueue.main.async {
                guard self.initialId == self.cell?.id else {return}
                
                if let video = video {
                    self.video = video
                    completion?(true)
                } else {
                    
                    completion?(false)
                }
            }
        }
    }

    
    func loadThumbnail() {
        if let thumbUrls = video?.thumbnailURLs, !thumbUrls.isEmpty {
            let url = thumbUrls.last!
            
            var request = URLRequest(url: url)
            request.cachePolicy = URLRequest.CachePolicy.returnCacheDataElseLoad

            Self.imageLoader.load(with: request) { image, error in
                if let image = image {
                    DispatchQueue.main.async {
                        guard self.initialId == self.cell?.id else { return }
                        
                        UIView.animate(withDuration: 0.3){
                            self.cell?.preloadThumb.image = image
                            self.cell?.preloadThumb.alpha = 1
                        } completion: { _ in
                            self.cell?.finishShowingInfoContainer(duration: 0)
                        }
                        self.cell?.thumbView.image = image
                        self.cell?.thumbView.alpha = 1
                    }
                }
            }
        }
    }
    

    private func player(for video: XCDYouTubeVideo, lowQualityMode: Bool = false) -> AVPlayer{

        if lowQualityMode {
            guard let streamURL = video.streamURLs[XCDYouTubeVideoQualityHTTPLiveStreaming] ?? video.streamURLs[XCDYouTubeVideoQuality.HD720] ?? video.streamURLs[XCDYouTubeVideoQuality.medium360.rawValue] ?? video.streamURLs[XCDYouTubeVideoQuality.small240.rawValue] else { fatalError("No stream URL") }
            return AVPlayer(url: streamURL)
        } else {
            let streamURL = video.streamURL
            return AVPlayer(url: streamURL!)
        }
    }
    
    deinit {
        print("tuner deinited")
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


