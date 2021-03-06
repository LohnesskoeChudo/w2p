//
//  CDVideo.swift
//  w2p
//
//  Created by vas on 20.02.2021.
//

import CoreData

class CDVideo: NSManagedObject {
    convenience init(context: NSManagedObjectContext, entity: NSEntityDescription, video: Video){
        
        self.init(entity: entity, insertInto: context)
        
        self.videoId = video.videoId
        self.id = Int64(video.id)
        self.name = video.name
    }
}

extension Video {
    init?(cdVideo: CDVideo){
        self.id = Int(cdVideo.id)
        if let videoId = cdVideo.videoId {
            self.videoId = videoId
        } else {
            return nil
        }
        if let name = cdVideo.name {
            self.name = name
        } else {
            return nil
        }
    }
}
