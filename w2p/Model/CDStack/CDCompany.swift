//
//  CDCompany.swift
//  w2p
//
//  Created by vas on 06.03.2021.
//
import CoreData

class CDCompany: NSManagedObject {
    
    convenience init?(context: NSManagedObjectContext, entity: NSEntityDescription, company: Company){
        
        guard let id = company.id else { return nil }
        guard let name = company.name else { return nil }
        self.init(entity: entity, insertInto: context)
        self.name = name
        self.id = Int64(id)
    }
}

extension Company {
    convenience init? (cdCompany: CDCompany){
        self.init()
        self.id = Int(cdCompany.id)
        self.name = cdCompany.name
    }
}
