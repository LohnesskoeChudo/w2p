//
//  TapticManager.swift
//  w2p
//
//  Created by vas on 09.03.2021.
//

import UIKit

class FeedbackManager {
    
    static let feedBackGenerator = UIImpactFeedbackGenerator(style: .light)
    
    static func generateFeedbackForButtonsTapped() {
        if GlobalSettings.shared.hapticFeedback {
            feedBackGenerator.impactOccurred()
        }
    }
}


