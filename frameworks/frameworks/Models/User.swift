//
//  User.swift
//  frameworks
//
//  Created by Владислав Лихачев on 21.01.2021.
//

import Foundation
import RealmSwift

class User: Object {
    @objc dynamic var login : String? = nil
    @objc dynamic var password : String? = nil
    
    override static func primaryKey() -> String? {
        return "login"
    }
}
