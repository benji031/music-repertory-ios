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
    
    func get(previousMusic music: Music, on repertory: Repertory) -> Music? {
        return nil
    }
    
    func get(nextMusic music: Music, on repertory: Repertory) -> Music? {
        return nil
    }
    
    
    
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
    
    func create(pdfMusicWithName name: String, andPdfFile pdfFile: Data, in repertory: Repertory) -> PDFMusic?  {
        guard let context  = repertory.managedObjectContext else {
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
        
        insert(music: music, in: repertory)
        
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
    
    func get(musicsFor repertory: Repertory) -> [Music] {
        return (repertory.musics?.compactMap({($0 as! RepertoryMusic).music })) ?? [Music]()
    }
    
    func getDocumentURL(for music: PDFMusic) -> URL? {
        guard let filename = music.documentPath else {
            return nil
        }
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(kBaseRepertoryDirectory, isDirectory: true).appendingPathComponent(filename)
    }
}
