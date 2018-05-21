//
//  MusicServiceImpl.swift
//  Paroles
//
//  Created by Benjamin DENEUX on 15/05/2018.
//  Copyright © 2018 Bananapps. All rights reserved.
//

import Foundation
import CoreData

class MusicServiceImpl: MusicService {

    let dataService: DataService?
    
    init(with dataService: DataService?) {
        self.dataService = dataService
    }
    
    func getMusics(on repertoire: Repertoire) -> [Music] {
        let request: NSFetchRequest<Music> = Music.fetchRequest()
        return dataService?.fetchObjects(request: request) ?? []
    }
    
    
    
    func saveMusic(withName name: String) -> Music? {
        guard let music = dataService?.create(type: Music.self, entityName: "Music") else {
            return nil
        }
        music.name = name
        dataService?.save(music)
        return music
    }
    
}
