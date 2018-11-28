//
//  MusicStorage.swift
//  Alamofire
//
//  Created by lcf on 2018/11/26.
//

import UIKit
import RealmSwift

public class MusicStorage: NSObject {

    static let shared = MusicStorage()
    
    public lazy var realm = try! Realm(configuration: self.realmConfig)
}

// MARK: - Configuration
public extension MusicStorage {
    
    public var storageURL: URL {
        return FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0].appendingPathComponent("MusicStorage")
    }
    
    public var realmSchemaVersion: UInt64 {
        return 1
    }
    
    public var realmConfig: Realm.Configuration {
        return Realm.Configuration(
            fileURL: storageURL.appendingPathComponent("data.realm"),
            schemaVersion: realmSchemaVersion,
            migrationBlock: { migration, oldSchemaVersion in })
    }
}
