//
//  MusicViewControllable.swift
//  Paroles
//
//  Created by Benjamin DENEUX on 01/12/2018.
//  Copyright © 2018 Bananapps. All rights reserved.
//

import UIKit

enum Direction {
    case next
    case previous
}

enum Position {
    case start
    case page(index: Int)
    case end
}

protocol MusicViewControllable {
    
    func has(_ direction: Direction) -> Bool
    func go(to direction: Direction)
    func go(at position: Position, animated: Bool)
    
}
