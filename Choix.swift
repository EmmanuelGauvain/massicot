//
//  Choix.swift
//  Massicot
//
//  Created by vaneffen on 14/05/2015.
//  Copyright (c) 2015 EMG. All rights reserved.
//

import SpriteKit

// #1
let NumberOfChoix: UInt32 = 6

// #2
enum ChoixType: Int, CustomStringConvertible {
    
    // #3
    case Blue = 0, Orange, Purple, Red, Teal, Yellow
    
    // #4
    var spriteNom: String {
        switch self {
        case .Blue:
            return "blue"
        case .Orange:
            return "orange"
        case .Purple:
            return "purple"
        case .Red:
            return "red"
        case .Teal:
            return "teal"
        case .Yellow:
            return "yellow"
        }
    }
    
    // #5
    var description: String {
        return self.spriteNom
    }
    
    // #6
    static func random() -> BlockColor {
        return BlockColor(rawValue:Int(arc4random_uniform(NumberOfColors)))!
    }
}

class Choix: Hashable, CustomStringConvertible {
    // #2
    // Constants
    let color: BlockColor
    
    // #3
    // Properties
    var column: Int
    var row: Int
    var sprite: SKSpriteNode?
    
    // #4
    var spriteName: String {
        return color.spriteName
    }
    
    // #5
    var hashValue: Int {
        return self.column ^ self.row
    }
    
    // #6
    var description: String {
        return "\(color): [\(column), \(row)]"
    }
    
    init(column:Int, row:Int, color:BlockColor) {
        self.column = column
        self.row = row
        self.color = color
    }
}

// #7
func ==(lhs: Choix, rhs: Choix) -> Bool {
    return lhs.column == rhs.column && lhs.row == rhs.row && lhs.color.rawValue == rhs.color.rawValue
}
