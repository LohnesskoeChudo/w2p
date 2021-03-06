//
//  CDCompany.swift
//  w2p
//
//  Created by vas on 06.03.2021.
//
import CoreData

class CDCompany: NSManagedObject {
    
    convenience init(context: NSManagedObjectContext, entity: NSEntityDescription, company: Company){
        
        self.init(entity: entity, insertInto: context)
        self.name = company.name
        self.id = Int64(company.id)
    }
}

extension Company {
    init? (cdCompany: CDCompany){
        self.id = Int(cdCompany.id)
        if let name = cdCompany.name {
            self.name = name
        } else {
            return nil
        }
    }
}
