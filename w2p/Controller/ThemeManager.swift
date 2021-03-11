//
//  ThemeManager.swift
//  w2p
//
//  Created by vas on 09.03.2021.
//

import UIKit

class ThemeManager {
        
    static func contentItemsHaveShadows(trait: UITraitCollection) -> Bool{
        
        switch trait.userInterfaceStyle {
        case .dark:
            return false
        case .light:
            return true
        default:
            return false
        }

    }
    
    static func colorForContentItemBackground(trait: UITraitCollection) -> UIColor {
        switch trait.userInterfaceStyle {
        case .dark:
            return UIColor(red: 0.075, green: 0.075, blue: 0.075, alpha: 1)
        default:
            return UIColor(red: 0.925, green: 0.925, blue: 0.925, alpha: 1)
        }
    }
    
    static func colorForGameModeAttribute(trait: UITraitCollection) -> UIColor {
        switch trait.userInterfaceStyle {
        case .dark:
            return #colorLiteral(red: 0.525052259, green: 0.2893972349, blue: 0, alpha: 1)
        default:
            return #colorLiteral(red: 1, green: 0.8076083209, blue: 0.4960746166, alpha: 1)
        }
    }
    
    static func colorForThemeAttribute(trait: UITraitCollection) -> UIColor {
        switch trait.userInterfaceStyle {
        case .dark:
            return #colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 1)
        default:
            return #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
        }
    }
    

    static func colorForPlatformAttribute(trait: UITraitCollection) -> UIColor {
        switch trait.userInterfaceStyle {
        case .dark:
            return #colorLiteral(red: 0.0007424146735, green: 0.3201038011, blue: 0.4539862691, alpha: 1)
        default:
            return #colorLiteral(red: 0.6431318682, green: 0.9051599392, blue: 1, alpha: 1)
        }
    }
    
    static func colorForGenreAttribute(trait: UITraitCollection) -> UIColor{
        switch trait.userInterfaceStyle {
        case .dark:
            return #colorLiteral(red: 0.2485453866, green: 0.01759905539, blue: 0.4539862691, alpha: 1)
        default:
            return #colorLiteral(red: 0.8042978662, green: 0.6273220038, blue: 1, alpha: 1)
        }
    }
    
    static func colorForUIelementsBackground(trait: UITraitCollection) -> UIColor{
        switch trait.userInterfaceStyle {
        case .dark:
            return #colorLiteral(red: 0.2056828997, green: 0.2056828997, blue: 0.2056828997, alpha: 1)
        default:
            return #colorLiteral(red: 0.7868020305, green: 0.7868020305, blue: 0.7868020305, alpha: 1)
        }
    }
    
    static func colorForSelection(trait: UITraitCollection) -> UIColor {
        switch trait.userInterfaceStyle {
        case .dark:
            return #colorLiteral(red: 0.538071066, green: 0.03520695572, blue: 0, alpha: 1)
        default:
            return #colorLiteral(red: 0.8730964467, green: 0.5305987029, blue: 0.5387735314, alpha: 1)
        }
    }
    

}
