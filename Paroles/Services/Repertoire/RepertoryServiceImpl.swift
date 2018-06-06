//
//  RepertoireServiceImpl.swift
//  Paroles
//
//  Created by Benjamin DENEUX on 15/05/2018.
//  Copyright © 2018 Bananapps. All rights reserved.
//

import Foundation
import CoreData

class RepertoryServiceImpl: RepertoryService {
    
    
    let dataService: DataService?
    
    init(with dataService: DataService?) {
        self.dataService = dataService
    }
    
    func create(repertoryWithName name: String) -> Repertory? {
        guard let repertory = dataService?.create(type: Repertory.self, entityName: "Repertory") else {
            return nil
        }
        repertory.name = name
        dataService?.save(repertory)
        return repertory
    }
    
    func getRepertories() -> [Repertory] {
        let request: NSFetchRequest<Repertory> = Repertory.fetchRequest()
        return dataService?.fetchObjects(request: request) ?? []
    }
    
    func create(pdfMusicWithName name: String, andPdfFile pdfFile: URL) -> PDFMusic?  {
        guard let music = dataService?.create(type: PDFMusic.self, entityName: "PDFMusic") else {
            return nil
        }
        music.name = name
        dataService?.save(music)
        return music
    }
    
    func insert(music: Music, in repertory: Repertory) -> Repertory {
        return Repertory()
    }
    
}
