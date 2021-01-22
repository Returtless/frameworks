//
//  RealmService.swift
//  frameworks
//
//  Created by Владислав Лихачев on 21.01.2021.
//

import Foundation
import RealmSwift

class RealmService {
    
    static func getDataFromRealm<T : Object>() -> [T]{
        do {
            let realm = try Realm()
            let data = realm.objects(T.self)
            return Array(data.map({$0 as T}))
        } catch {
            print(error)
        }
        return Array()
    }
    
    static func getDataFromRealm<T : Object>(with filter: String) -> [T]{
        do {
            let realm = try Realm()
            let data = realm.objects(T.self).filter(filter)
            return Array(data.map({$0 as T}))
        } catch {
            print(error)
        }
        return Array()
    }
    
    static func saveDataToRealm<T : Object>(_ obj: T) {
        do {
            Realm.Configuration.defaultConfiguration = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
            let realm = try Realm()
            //print(realm.configuration.fileURL)
            realm.beginWrite()
            realm.add(obj, update: .modified)
            try realm.commitWrite()
        } catch {
            print(error)
        }
    }
    
    static func saveDataToRealm<T : Object>(_ array: [T]) {
            do {
                Realm.Configuration.defaultConfiguration = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
                let realm = try Realm()
                print(realm.configuration.fileURL)
                let oldData = realm.objects(T.self)
                realm.beginWrite()
                realm.delete(oldData)
                realm.add(array)
                try realm.commitWrite()
            } catch {
                print(error)
            }
        }
}
