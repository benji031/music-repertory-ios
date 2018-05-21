//
//  MusicService.swift
//  Paroles
//
//  Created by Benjamin DENEUX on 15/05/2018.
//  Copyright © 2018 Bananapps. All rights reserved.
//

import Foundation

protocol MusicService {
    
    func saveMusic(withName name: String) -> Music?
    
    func getMusics(on repertoire: Repertoire) -> [Music]
    
}
