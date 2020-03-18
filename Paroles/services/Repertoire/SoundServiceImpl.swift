//
//  SoundServiceImpl.swift
//  Paroles
//
//  Created by Benjamin DENEUX on 18/03/2020.
//  Copyright © 2020 Bananapps. All rights reserved.
//

import Foundation
import CoreData

let kBaseSoundsDirectory = "sound"

class SoundServiceImpl: SoundService {
    
    let dataService: DataService?
    
    init(with dataService: DataService?) {
        self.dataService = dataService
    }
    
    func find(soundsFor music: Music) -> [Sound] {
        guard let context = music.managedObjectContext else {
            return []
        }
        
        let request: NSFetchRequest<Sound> = Sound.fetchRequest()
        request.predicate = NSPredicate(format: "music == %@", music)
        return dataService?.fetchObjects(request: request, on: context) ?? []
    }
    
    func `import`(soundFromFile url: URL, for music: Music) -> Sound? {
        guard let context = music.managedObjectContext else {
            return nil
        }
        
        guard let sound = dataService?.create(type: Sound.self, entityName: "Sound", in: context) else {
            return nil
        }
        
        let isSecured = url.startAccessingSecurityScopedResource()
        let coordinator = NSFileCoordinator()
        var error: NSError? = nil
        
        coordinator.coordinate(readingItemAt: url, options: [.forUploading], error: &error) { (url) in
            
            do {
                let fileName = UUID().uuidString
                let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(kBaseSoundsDirectory, isDirectory: true)
                try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
                let newURL = directory.appendingPathComponent(fileName)
                // TODO: Copy unstead of data loading.
                // Copy not working, try later to do properly unstead of load document in memory...
    //                try FileManager.default.copyItem(at: url, to: newURL)
                let data = try Data(contentsOf: url)
                try data.write(to: newURL)
                
                sound.path = fileName
                sound.name = url.lastPathComponent
                sound.music = music
                dataService?.save(sound)
            }
            catch let error {
                Log("An error occured trying to copy file to local sound repertory! \(error.localizedDescription)")
                return
            }
            
        }
        if let error = error {
            Log("An error occured trying to copy file to local sound repertory! \(error.localizedDescription)")
            return nil
        }
        
        if isSecured { url.stopAccessingSecurityScopedResource() }
        
        return sound
    }
    
    func getSoundURL(for sound: Sound) -> URL? {
        guard let filename = sound.path else {
            return nil
        }
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(kBaseSoundsDirectory, isDirectory: true).appendingPathComponent(filename)
    }
}
