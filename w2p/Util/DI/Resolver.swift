//
//  Resolver.swift
//  w2p
//
//  Created by Vasiliy Klyotskin on 15.04.2021.
//

import Foundation
import Swinject

class Resolver {
    static let shared = Resolver()
    var container = Container()
    
    private init() {}
}
