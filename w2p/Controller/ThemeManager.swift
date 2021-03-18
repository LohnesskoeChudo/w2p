//
//  ThemeManager.swift
//  w2p
//
//  Created by vas on 09.03.2021.
//

import UIKit

class ThemeManager {
    

    static weak var window: UIWindow? {
        didSet {
            updateUIAppearance()
        }
    }
        
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
            return #colorLiteral(red: 0.260559846, green: 0.4574839627, blue: 0.1409400448, alpha: 1)
        default:
            return #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
        }
    }
    
    static func darkVersion(of color: UIColor) -> UIColor {
        let coef: CGFloat = 0.5
        let ciColor = CIColor(cgColor: color.cgColor)
        let newRed = ciColor.red * coef
        let newBlue = ciColor.blue * coef
        let newGreen = ciColor.green * coef
        return UIColor(red: newRed, green: newGreen, blue: newBlue, alpha: 1)
    }
    
    static func lightVersion(of color: UIColor) -> UIColor{
        let coef: CGFloat = 1.35
        let newRed = color.ciColor.red * coef
        let newBlue = color.ciColor.blue * coef
        let newGreen = color.ciColor.green * coef
        if newRed > 1 || newBlue > 1 || newGreen > 1 {
            return color
        }
        return UIColor(red: newRed, green: newGreen, blue: newBlue, alpha: 1)
    }
    

    static func colorForPlatformAttribute(trait: UITraitCollection) -> UIColor {
        switch trait.userInterfaceStyle {
        case .dark:
            return #colorLiteral(red: 0.1691063247, green: 0.4153711193, blue: 0.5846724425, alpha: 1)
        default:
            return #colorLiteral(red: 0.6431318682, green: 0.9051599392, blue: 1, alpha: 1)
        }
    }
    
    static func colorForGenreAttribute(trait: UITraitCollection) -> UIColor{
        switch trait.userInterfaceStyle {
        case .dark:
            return #colorLiteral(red: 0.4125262704, green: 0.2544650949, blue: 0.7194695304, alpha: 1)
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
            return #colorLiteral(red: 0.6015228426, green: 0.05500181201, blue: 0.2388803586, alpha: 1)
        default:
            return #colorLiteral(red: 0.8730964467, green: 0.5305987029, blue: 0.5387735314, alpha: 1)
        }
    }
    
    static func firstColorForImagePlaceholder(trait: UITraitCollection) -> UIColor {
        switch trait.userInterfaceStyle {
        case .dark:
            return #colorLiteral(red: 0.1549214784, green: 0.1549214784, blue: 0.1549214784, alpha: 1)
        default:
            return #colorLiteral(red: 0.9340101522, green: 0.9340101522, blue: 0.9340101522, alpha: 1)
        }
    }
    
    static func secondColorForImagePlaceholder(trait: UITraitCollection) -> UIColor{
        switch trait.userInterfaceStyle {
        case .dark:
            return #colorLiteral(red: 0.08629441624, green: 0.08629441624, blue: 0.08629441624, alpha: 1)
        default:
            return #colorLiteral(red: 0.8207532772, green: 0.8288795473, blue: 0.8288795473, alpha: 1)
        }
    }
    
    static func colorForBarButtons(trait: UITraitCollection) -> UIColor {
        switch trait.userInterfaceStyle {
        case .dark:
            return #colorLiteral(red: 0.4064115251, green: 0.6955276374, blue: 1, alpha: 1)
        default:
            return #colorLiteral(red: 0.2558123305, green: 0.4377940459, blue: 0.6294416244, alpha: 1)
        }
    }
    
    static func colorForPlainButtons(trait: UITraitCollection) -> UIColor {
        switch trait.userInterfaceStyle {
        case .dark:
            return #colorLiteral(red: 0.4064115251, green: 0.6955276374, blue: 1, alpha: 1)
        default:
            return #colorLiteral(red: 0.2558123305, green: 0.4377940459, blue: 0.6294416244, alpha: 1)
        }
    }
    
    static func colorForWebsite(trait: UITraitCollection) -> UIColor {
        switch trait.userInterfaceStyle {
        case .dark:
            return #colorLiteral(red: 0.5076142132, green: 0.1377298433, blue: 0.2437737922, alpha: 1)
        default:
            return #colorLiteral(red: 1, green: 0.4878630806, blue: 0.534561437, alpha: 1)
        }
    }

    private static func uiStyleForCurrentAppearanceMode() -> UIUserInterfaceStyle{
        if GlobalSettings.shared.darkMode {
            return .dark
        } else {
            return.light
        }
    }
    
    static func updateUIAppearance() {
        window?.overrideUserInterfaceStyle = uiStyleForCurrentAppearanceMode()
    }
    
    

}

