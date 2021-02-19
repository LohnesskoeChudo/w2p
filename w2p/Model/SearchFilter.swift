//
//  SearchFilter.swift
//  w2p
//
//  Created by vas on 13.02.2021.
//

import Foundation

class SearchFilter{
    
    var genres: [GameGenre] = []
    var themes: [GameTheme] = []
    var platforms: [GamePlatform] = []
    var rating: ClosedRange<Double>? = nil
    var isReleased: Bool? = nil
    var releasedDateRange: ClosedRange<Date>? = nil
    
    var allGenres: [GameGenre] = []
    var allThemes: [GameTheme] = []
    var allPlatforms: [GamePlatform] = []
    
    func resetToDefault(){
        genres = []
        themes = []
        platforms = []
        rating = nil
        isReleased = nil
        releasedDateRange = nil
    }
}
