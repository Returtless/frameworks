//
//  CoordsModel.swift
//  frameworks
//
//  Created by Владислав Лихачев on 18.01.2021.
//

import Foundation
import RealmSwift

class CoordsModel: Object {
    @objc dynamic var lat : String? = nil
    @objc dynamic var long : String? = nil
}
