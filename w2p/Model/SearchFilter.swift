//
//  SearchFilter.swift
//  w2p
//
//  Created by vas on 13.02.2021.
//

import Foundation

class SearchFilter{
    
    var searchString: String?
    var genres: Set<Genre> = []
    var themes: Set<Theme> = []
    var platforms: Set<Platform> = []
    
    var singleplayer: Bool = false
    var multiplayer: Bool = false

    var ratingUpperBound: Int?
    var ratingLowerBound: Int?

    var releaseDateUpperBound: Date?
    var releaseDateLowerBound: Date?
    
    var excludeWithoutDescription: Bool = true
    var excludeWithoutCover: Bool = true

    static var allGenres: [Genre] = {
        loadAllGameAttributes(resourceName: "genres") ?? []
    }()
    static var allThemes: [Theme] = {
        loadAllGameAttributes(resourceName: "themes") ?? []
    }()
    static var allPlatforms: [Platform] = {
        loadAllGameAttributes(resourceName: "platforms") ?? []
    }()
    
    static var mainPlatforms: [Platform] = {
        loadAllGameAttributes(resourceName: "mainPlatforms") ?? []
    }()
    
    
    static func loadAllGameAttributes<A>(resourceName: String) -> [A]? where A: Decodable{
        if let path = Bundle.main.path(forResource: resourceName, ofType: "json"),
           let data = try? Data(contentsOf: URL(fileURLWithPath: path)){
            
            let jsonDecoder = JSONDecoder()
            if let decodedAttrs = try? jsonDecoder.decode([A].self, from: data){
                return decodedAttrs
            }
        }
        return nil
    }
    
    func resetToDefault(){
        genres = []
        themes = []
        platforms = []
        singleplayer = false
        multiplayer = false
        ratingUpperBound = nil
        ratingLowerBound = nil
        releaseDateLowerBound = nil
        releaseDateUpperBound = nil
        
        excludeWithoutCover = true
        excludeWithoutDescription = true
    }
}
