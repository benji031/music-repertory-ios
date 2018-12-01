//
//  MusicViewControllable.swift
//  Paroles
//
//  Created by Benjamin DENEUX on 01/12/2018.
//  Copyright © 2018 Bananapps. All rights reserved.
//

import Foundation

enum Direction {
    case next
    case previous
}

protocol MusicViewControllable {
    
    func has(_ direction: Direction) -> Bool
    func go(to direction: Direction)
}
