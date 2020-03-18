//
//  PDFMusic+CoreDataProperties.swift
//  Paroles
//
//  Created by Benjamin DENEUX on 18/03/2020.
//  Copyright © 2020 Bananapps. All rights reserved.
//
//

import Foundation
import CoreData


extension PDFMusic {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PDFMusic> {
        return NSFetchRequest<PDFMusic>(entityName: "PDFMusic")
    }

    @NSManaged public var documentPath: String?

}
