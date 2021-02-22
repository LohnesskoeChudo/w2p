//
//  Headers.swift
//  w2p
//
//  Created by vas on 22.02.2021.
//

import Foundation

class RequestFields{
    
    static var basicFields =
    """
        fields
        name,
        category,
        summary,
        storyline,
        aggregated_rating,
        status,
        first_release_date,
        similar_games,
        cover.animated, cover.height, cover.width, cover.url,
        genres.name,
        platforms.name,
        game_modes.name,
        websites.url, websites.category,
        themes.name,
        artworks.animated, artworks.height, artworks.width, artworks.url,
        screenshots.animated, screenshots.height, screenshots.width, screenshots.url,
        videos.name, videos.video_id,
        franchise.games, franchise.name,
        collection.games, collection.name,
        age_ratings.category, age_ratings.rating, age_ratings.rating_cover_url;
    """
    
    
    
}
