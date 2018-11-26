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
    
    public lazy var realm = try! Realm(configuration: realmConfig)
}

// MARK: - Configuration
private extension MusicStorage {
    
    private var storageURL: URL {
        return FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0].appendingPathComponent("MusicStorage")
    }
    
    private var realmSchemaVersion: UInt64 {
        return 1
    }
    
    private var realmConfig: Realm.Configuration {
        return Realm.Configuration(
            fileURL: storageURL.appendingPathComponent("data.realm"),
            schemaVersion: realmSchemaVersion,
            migrationBlock: { migration, oldSchemaVersion in })
    }
}
