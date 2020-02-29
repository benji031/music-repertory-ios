//
//  RepertoireServiceImpl.swift
//  Paroles
//
//  Created by Benjamin DENEUX on 15/05/2018.
//  Copyright © 2018 Bananapps. All rights reserved.
//

import Foundation
import CoreData

let kBaseRepertoryDirectory = "repertory"

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
    
    func create(pdfMusicWithName name: String, andPdfFile pdfFile: Data, in repertory: Repertory? = nil) -> PDFMusic?  {
        guard let context = repertory != nil ? repertory!.managedObjectContext : dataService?.getPrivateContext() else {
            return nil
        }
        
        guard let music = dataService?.create(type: PDFMusic.self, entityName: "PDFMusic", in: context) else {
            return nil
        }
        
        let fileName = UUID().uuidString
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(kBaseRepertoryDirectory, isDirectory: true)
        try! FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        let newURL = directory.appendingPathComponent(fileName)
        try! pdfFile.write(to: newURL)
        
        music.name = name
        music.documentPath = fileName
        dataService?.save(music)
        
        if let repertory = repertory {
            insert(music: music, in: repertory)
        }
        
        return music
    }
    
    @discardableResult
    func insert(music: Music, in repertory: Repertory) -> Repertory {
        guard let context  = repertory.managedObjectContext else {
            return repertory
        }
        
        guard let repertoryMusic = dataService?.create(type: RepertoryMusic.self, entityName: "RepertoryMusic", in: context) else {
            return repertory
        }
        repertoryMusic.repertory = repertory
        repertoryMusic.music = music
        
        repertory.addToMusics(repertoryMusic)
        
        dataService?.save(context)
        return repertory
    }
    
    func getMusics(in context: NSManagedObjectContext?) -> [Music] {
        guard let context = context != nil ? context : dataService?.getPrivateContext() else {
            return []
        }
        
        let request: NSFetchRequest<Music> = Music.fetchRequest()
        return dataService?.fetchObjects(request: request, on: context) ?? []
    }
    
    func get(musicsFor repertory: Repertory) -> [RepertoryMusic] {
        return (repertory.musics?
            .compactMap({($0 as! RepertoryMusic) })
            .sorted(by: { $0.index < $1.index })) ?? [RepertoryMusic]()
    }
    
    func getDocumentURL(for music: PDFMusic) -> URL? {
        guard let filename = music.documentPath else {
            return nil
        }
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(kBaseRepertoryDirectory, isDirectory: true).appendingPathComponent(filename)
    }
    
    func add(_ music: Music, to repertory: Repertory) {
        let _ = insert(music: music, in: repertory)
    }
    
    func remove(_ music: Music, from repertory: Repertory) {
        guard let repertoryMusic = repertory.musics?.first(where: { ($0 as! RepertoryMusic).music == music }) as? RepertoryMusic else {
            return
        }
        
        repertory.removeFromMusics(repertoryMusic)
        
        dataService?.save(repertoryMusic)
        dataService?.delete(repertoryMusic)
    }

    func saveOrder(_ repertoryMusics: [RepertoryMusic], in repertory: Repertory) {
        for (i, repertoryMusic) in repertoryMusics.enumerated() {
            repertoryMusic.index = Int32(i)
            dataService?.save(repertoryMusic)
        }
    }
    
    func save(_ music: Music) -> Music? {
        dataService?.save(music)
        return music
    }
}
