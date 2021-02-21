//
//  SearchFilter.swift
//  w2p
//
//  Created by vas on 13.02.2021.
//

import Foundation

class SearchFilter{
    
    var genres: [Genre] = []
    var themes: [Theme] = []
    var platforms: [Platform] = []
    var rating: ClosedRange<Double>? = nil
    var isReleased: Bool? = nil
    var releasedDateRange: ClosedRange<Date>? = nil
    
    var allGenres: [Genre] = []
    var allThemes: [Theme] = []
    var allPlatforms: [Platform] = []
    
    func resetToDefault(){
        genres = []
        themes = []
        platforms = []
        rating = nil
        isReleased = nil
        releasedDateRange = nil
    }
}
