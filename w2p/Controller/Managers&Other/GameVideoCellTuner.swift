import AVKit
import Foundation
import XCDYouTubeKit


class GameVideoCellTuner: NSObject, AVPlayerViewControllerDelegate {
    
    static var imageLoader = Resolver.shared.container.resolve(PImageLoader.self)!
    private weak var cell: GameVideoCompactCell?
    private var videoId: String
    private var video: XCDYouTubeVideo?
    private var player: AVPlayer?
    private var initialId: UUID?
    private var playerIsReadyToken: NSKeyValueObservation?
    private var playerStatusToken: NSKeyValueObservation?
    private var connectionIsLostToken: NSKeyValueObservation?
    
    init(cell: GameVideoCompactCell, videoId: String, parentVC: UIViewController) {
        self.videoId = videoId
        super.init()
        cell.id = UUID()
        self.initialId = cell.id
        self.cell = cell
        if self.cell?.isSetup == false {
            self.cell?.setupPlayerController(parentVC: parentVC)
            self.cell?.isSetup = true
        }
    }
    
    func setup() {
        cell?.isLoading = true
        cell?.startLoadingAnimation()
        getYTvideo(){ success in
            DispatchQueue.global(qos: .userInitiated).async {
                if success {
                    self.setPlayer()
                    DispatchQueue.main.async {
                        self.cell?.avPlayerController.player = self.player
                    }
                    self.loadThumbnail()
                } else {
                    DispatchQueue.main.async {
                        self.cell?.isLoading = false
                    }
                    self.cell?.finishShowingInfoContainer(duration: 0.3) {
                        self.cell?.showConnectionProblemMessage(duration: 0.3)
                    }
                }
            }
        }
    }
    
    func reload() {
        self.initialId = UUID()
        self.cell?.id = self.initialId
        self.cell?.finishShowingInfoContainer(duration: 0.3) {
            self.setup()
        }
    }

    private func getYTvideo(completion: ((_ succes: Bool)->Void)? = nil) {
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

    private func loadThumbnail() {
        if let thumbUrls = video?.thumbnailURLs, !thumbUrls.isEmpty {
            let url = thumbUrls.last!
            
            var request = URLRequest(url: url)
            request.cachePolicy = URLRequest.CachePolicy.returnCacheDataElseLoad

            Self.imageLoader.load(with: request) { image, error in
                if let image = image {
                    
                    DispatchQueue.main.async {
                        let cellWidth = self.cell?.frame.width

                        DispatchQueue.global(qos: .userInitiated).async {
                            
                            var imageToSet: UIImage?
                            
                            if let width = cellWidth {
                                imageToSet = ImageResizer.resizeImageToFit(width: width, image: image)
                            } else {
                                imageToSet = image
                            }
                            
                            DispatchQueue.main.async {
                                guard self.initialId == self.cell?.id else { return }
    
                                UIView.animate(withDuration: 0.3){
                                    self.cell?.preloadThumb.image = imageToSet
                                    self.cell?.preloadThumb.alpha = 1
                                }
                                self.cell?.thumbView.image = imageToSet
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func setPlayer(lowQualityMode: Bool = false) {
        if lowQualityMode {
            guard let streamURL = video?.streamURLs[XCDYouTubeVideoQualityHTTPLiveStreaming] ?? video?.streamURLs[XCDYouTubeVideoQuality.HD720] ?? video?.streamURLs[XCDYouTubeVideoQuality.medium360.rawValue] ?? video?.streamURLs[XCDYouTubeVideoQuality.small240.rawValue] else { fatalError("No stream URL") }
           self.player = AVPlayer(url: streamURL)
        } else {
            if let streamURL = video?.streamURL {
                
                self.player = AVPlayer(url: streamURL)
            }
        }
        
        player?.automaticallyWaitsToMinimizeStalling = false
        playerStatusToken?.invalidate()
        playerStatusToken = player?.observe(\.timeControlStatus , options: [.new]) { [weak self]
            
            player, _ in
            if player.timeControlStatus == .playing {
                self?.cell?.thumbView.image = nil
            }
        }
        playerIsReadyToken?.invalidate()
        playerIsReadyToken = player?.observe(\.currentItem?.isPlaybackLikelyToKeepUp, options: [.new]) { [weak self]
            avvc , _ in
            
            if self?.player?.currentItem?.isPlaybackLikelyToKeepUp == true {
                self?.cell?.finishShowingInfoContainer(duration: 0.2) {
                    self?.cell?.avPlayerController.view.alpha = 1
                }
                self?.cell?.isLoading = false
            }
        }
        
        connectionIsLostToken = player?.observe(\.currentItem?.error, options: [.new]) { [weak self]
            player, _ in
            
            self?.cell?.isLoading = false
            self?.cell?.finishShowingInfoContainer(duration: 0.3) {
                self?.cell?.showConnectionProblemMessage(duration: 0.3) {
                }
            }
        }
    }
    
    deinit {
        playerIsReadyToken?.invalidate()
        playerStatusToken?.invalidate()
        connectionIsLostToken?.invalidate()
    }
}





