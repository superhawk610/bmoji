//
//  Storage.swift
//  bmoji
//
//  Created by Aaron Ross on 10/27/20.
//

import Foundation

class Storage {
    
    static let shared = Storage()
    
    private var storageFile: URL? {
        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        let storageDir = homeDir.appendingPathComponent(".bmoji")
        
        do {
            try FileManager.default.createDirectory(at: storageDir, withIntermediateDirectories: true)
        } catch {
            print("Unable to create \(storageDir), persistence disabled")
            return nil
        }
        
        return storageDir.appendingPathComponent("config.json")
    }
    
    private var data: [String: Any] = [:]
    
    init() {
        self.load()
    }
    
    func get(_ key: String) -> Any? {
        return self.data[key]
    }
    
    func set(_ key: String, _ value: Any) {
        self.data[key] = value
        
        // TODO: save periodically instead of on each call to `set`
        self.persist()
    }
    
    func persist() {
        guard let storageFile = self.storageFile else {
            print("persistence disabled")
            return
        }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: self.data, options: [])
            try data.write(to: storageFile, options: [])
        } catch {
            // TODO: improve error handling
            print(error)
        }
    }
    
    private func load() {
        guard let storageFile = self.storageFile else {
            print("persistence disabled")
            return
        }
        
        do {
            let data = try Data(contentsOf: storageFile, options: [])
            guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] else { return }
            self.data = json
        } catch let error as NSError {
            if error.domain == NSCocoaErrorDomain && error.code == 260 {
                // file doesn't exist, which should be safe to ignore on first runs
            } else {
                // TODO: improve error handling
                print(error)
            }
        } catch {
            print(error)
        }
    }
    
}
