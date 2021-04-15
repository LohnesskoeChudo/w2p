//
//  FileManager+.swift
//  w2p
//
//  Created by vas on 09.03.2021.
//

import Foundation


extension FileManager {
    func documentsUrlForFile(with filename: String) -> URL?{
        if let documentDirectory = try? self.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            let fileUrl = documentDirectory.appendingPathComponent(filename)
            return fileUrl
        }
        return nil
    }
}
