//
//  CDVideo.swift
//  w2p
//
//  Created by vas on 20.02.2021.
//

import CoreData

class CDVideo: NSManagedObject {
    convenience init?(context: NSManagedObjectContext, entity: NSEntityDescription, video: Video){
        
        guard let id = video.id else { return nil }
        guard let videoId = video.videoId else { return nil }
        self.init(entity: entity, insertInto: context)
        
        self.videoId = videoId
        self.id = Int64(id)
        self.name = video.name
    }
}

extension Video {
    convenience init?(cdVideo: CDVideo){
        self.init()
        self.id = Int(cdVideo.id)
        self.videoId = cdVideo.videoId
        self.name = cdVideo.name
    }
}
