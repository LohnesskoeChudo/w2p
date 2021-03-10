//
//  TapticManager.swift
//  w2p
//
//  Created by vas on 09.03.2021.
//

import UIKit

class FeedbackManager {
    
    static let feedBackGenerator = UINotificationFeedbackGenerator()
    
    static func generateFeedbackForButtonsTapped() {
        if GlobalSettings.shared.controlHaptics {
            feedBackGenerator.notificationOccurred(.success)
        }
    }
}


