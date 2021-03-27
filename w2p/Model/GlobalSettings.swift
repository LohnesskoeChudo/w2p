//
//  GlobalSettings.swift
//  w2p
//
//  Created by vas on 09.03.2021.
//

import Foundation

class GlobalSettings: Codable {
    
    static let fileName = "settings"
    static let ext = "json"
    
    var hapticFeedback = true { didSet {save()} }
    var darkMode = true { didSet {save()} }
    
    static let shared: GlobalSettings = {
        if let fileUrl = FileManager.default.documentsUrlForFile(with: GlobalSettings.fileName), let data = try? Data(contentsOf: fileUrl) {
            if let decoded = try? JSONDecoder().decode(GlobalSettings.self, from: data) {
                
                return decoded
            }
        }
        return GlobalSettings()
    }()
    
    func save(){
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(self) {
            if let fileUrl = FileManager.default.documentsUrlForFile(with: Self.fileName){
                try? encoded.write(to: fileUrl)
            }
        }
    }
    
    
    private init() {
        
    }

}
