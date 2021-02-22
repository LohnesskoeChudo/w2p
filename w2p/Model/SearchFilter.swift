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
    var gameModes: Set<GameMode> = []
    var ratingUpperBound: Date?
    var ratingLowerBound: Date?
    var isReleased: Bool? = nil
    
    
    
    var releaseDateUpperBound: Date?
    var releaseDateLowerBound: Date?

    var allGenres: [Genre] = []
    var allThemes: [Theme] = []
    var allPlatforms: [Platform] = []
    
    func resetToDefault(){
        genres = []
        themes = []
        platforms = []
        isReleased = nil
    }
}
