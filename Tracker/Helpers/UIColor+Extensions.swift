//
//  UIColor+Extensions.swift
//  Tracker
//
//  Created by Анастасия on 04.01.2024.
//

import Foundation
import UIKit

extension UIColor {
    static var designBlack: UIColor { UIColor(named: "Black [day]") ?? UIColor.black }
    static var designWhite: UIColor { UIColor(named: "White [day]") ?? UIColor.white }
    static var designBlue: UIColor { UIColor(named: "Blue") ?? UIColor.blue }
    static var designGray: UIColor { UIColor(named: "Gray") ?? UIColor.gray }
    static var designLightGray: UIColor { UIColor(named: "Light Gray") ?? UIColor.gray }
    static var designBackground: UIColor { UIColor(named: "Background [day]") ?? UIColor.lightGray }
    static var designRed: UIColor { UIColor(named: "Red") ?? UIColor.red}
    static var designWhiteOp: UIColor { UIColor(named: "WhiteOp") ?? UIColor.white}
}

extension UIColor {
    static var colorSection1: UIColor { UIColor(named: "ColorSection1") ?? UIColor.red }
    static var colorSection2: UIColor { UIColor(named: "ColorSection2") ?? UIColor.orange }
    static var colorSection3: UIColor { UIColor(named: "ColorSection3") ?? UIColor.blue }
    static var colorSection4: UIColor { UIColor(named: "ColorSection4") ?? UIColor.purple }
    static var colorSection5: UIColor { UIColor(named: "ColorSection5") ?? UIColor.green }
    static var colorSection6: UIColor { UIColor(named: "ColorSection6") ?? UIColor.systemPink }
    static var colorSection7: UIColor { UIColor(named: "ColorSection7") ?? UIColor.systemPink }
    static var colorSection8: UIColor { UIColor(named: "ColorSection8") ?? UIColor.blue }
    static var colorSection9: UIColor { UIColor(named: "ColorSection9") ?? UIColor.green }
    static var colorSection10: UIColor { UIColor(named: "ColorSection10") ?? UIColor.purple }
    static var colorSection11: UIColor { UIColor(named: "ColorSection11") ?? UIColor.red }
    static var colorSection12: UIColor { UIColor(named: "ColorSection12") ?? UIColor.systemPink }
    static var colorSection13: UIColor { UIColor(named: "ColorSection13") ?? UIColor.yellow }
    static var colorSection14: UIColor { UIColor(named: "ColorSection14") ?? UIColor.purple }
    static var colorSection15: UIColor { UIColor(named: "ColorSection15") ?? UIColor.purple }
    static var colorSection16: UIColor { UIColor(named: "ColorSection16") ?? UIColor.purple }
    static var colorSection17: UIColor { UIColor(named: "ColorSection17") ?? UIColor.purple }
    static var colorSection18: UIColor { UIColor(named: "ColorSection18") ?? UIColor.green }
    
}

extension UIColor {
    func toHex() -> String {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }
    
    convenience init?(hexString: String) {
        var hexSanitized = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
