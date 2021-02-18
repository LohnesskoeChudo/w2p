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
    var released: Bool? = nil
    var releasedDateRange: ClosedRange<Date>? = nil
    
    var allGenres: [String] = []
    var allThemes: [String] = []
    var allPlatforms: [String] = []
    
    private var jsonLoader = JsonLoader()
    
    
    
}

protocol SearchFilterItem {
    var name: String {get set}
}
