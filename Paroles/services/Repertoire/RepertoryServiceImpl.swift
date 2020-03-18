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
let kBaseSoundsDirectoy = "sound"

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
    
    func `import`(pdfMusicFromFile url: URL, in repertory: Repertory?) -> PDFMusic? {
        
        guard let context = repertory != nil ? repertory!.managedObjectContext : dataService?.getPrivateContext() else {
            return nil
        }
        
        guard let music = dataService?.create(type: PDFMusic.self, entityName: "PDFMusic", in: context) else {
            return nil
        }
        
        let isSecured = url.startAccessingSecurityScopedResource()
        let coordinator = NSFileCoordinator()
        var error: NSError? = nil
        
        coordinator.coordinate(readingItemAt: url, options: [.forUploading], error: &error) { (url) in
            
            do {
                let fileName = UUID().uuidString
                let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(kBaseRepertoryDirectory, isDirectory: true)
                try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
                let newURL = directory.appendingPathComponent(fileName)
                // TODO: Copy unstead of data loading.
                // Copy not working, try later to do properly unstead of load document in memory...
//                try FileManager.default.copyItem(at: url, to: newURL)
                let data = try Data(contentsOf: url)
                try data.write(to: newURL)
                
                music.name = url.lastPathComponent
                music.documentPath = fileName
                dataService?.save(music)
                
                if let repertory = repertory {
                    insert(music: music, in: repertory)
                }
            }
            catch let error {
                Log("An error occured trying to copy file to local repertory! \(error.localizedDescription)")
                dataService?.delete(music)
                return
            }
            
        }
        if let error = error {
            Log("An error occured trying to copy file to local repertory! \(error.localizedDescription)")
            dataService?.delete(music)
            return nil
        }
        
        if isSecured { url.stopAccessingSecurityScopedResource() }
        
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
        
        repertoryMusic.index = (get(musicsFor: repertory).last?.index ?? -1 ) + 1
        
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
    
    func getSoundsURL(for music: Music) -> URL? {
        guard let filename = music.musicPath else {
            return nil
        }
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(kBaseSoundsDirectoy, isDirectory: true).appendingPathComponent(filename)
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
    
    func associateSound(_ soundUrl: URL, to music: Music) {
        let isSecured = soundUrl.startAccessingSecurityScopedResource()
        let coordinator = NSFileCoordinator()
        var error: NSError? = nil
        
        coordinator.coordinate(readingItemAt: soundUrl, options: [.forUploading], error: &error) { (url) in
            
            do {
                let fileName = UUID().uuidString + ".mp3"
                let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(kBaseSoundsDirectoy, isDirectory: true)
                try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
                let newURL = directory.appendingPathComponent(fileName)
                // TODO: Copy unstead of data loading.
                // Copy not working, try later to do properly unstead of load document in memory...
    //                try FileManager.default.copyItem(at: url, to: newURL)
                let data = try Data(contentsOf: url)
                try data.write(to: newURL)
                
                music.musicPath = fileName
                dataService?.save(music)
            }
            catch let error {
                Log("An error occured trying to copy file to local sound repertory! \(error.localizedDescription)")
                return
            }
            
        }
        if let error = error {
            Log("An error occured trying to copy file to local sound repertory! \(error.localizedDescription)")
            return
        }
        
        if isSecured { soundUrl.stopAccessingSecurityScopedResource() }
    }
}
