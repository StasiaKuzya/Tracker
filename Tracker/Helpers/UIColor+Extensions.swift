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
    static var designLightGray2: UIColor { UIColor(named: "LightGraySearchTextField") ?? UIColor.gray }
}
