//
//  SoundService.swift
//  Paroles
//
//  Created by Benjamin DENEUX on 18/03/2020.
//  Copyright © 2020 Bananapps. All rights reserved.
//

import Foundation

protocol SoundService {
    
    func find(soundsFor music: Music) -> [Sound]
    
    func `import`(soundFromFile url: URL, for music: Music) -> Sound?
    
    func remove(_ sound: Sound)
    func save(_ sound: Sound) -> Sound?
    
    func getSoundURL(for sound: Sound) -> URL?
}
