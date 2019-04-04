//
//  CellItem.swift
//  BMSv3
//
//  Created by Jayden Pereira on 4/3/19.
//  Copyright © 2019 Jayden Pereira. All rights reserved.
//

import Foundation

class CellItem: NSObject, NSCoding {
    var title: String
    var done: Bool
    
    init(title: String) {
        self.title = title
        self.done = false
    }
    
    func getMockData() -> [CellItem] {
        return [
            CellItem(title: "Test1"),
            CellItem(title: "Test2"),
            CellItem(title: "Test3")
        ]
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        // Try to unserialize the "title" variable
        if let title = aDecoder.decodeObject(forKey: "title") as? String
        {
            self.title = title
        }
        else
        {
            // There were no objects encoded with the key "title",
            // so that's an error.
            return nil
        }
        
        // Check if the key "done" exists, since decodeBool() always succeeds
        if aDecoder.containsValue(forKey: "done")
        {
            self.done = aDecoder.decodeBool(forKey: "done")
        }
        else
        {
            // Same problem as above
            return nil
        }
    }
    
    func encode(with aCoder: NSCoder)
    {
        // Store the objects into the coder object
        aCoder.encode(self.title, forKey: "title")
        aCoder.encode(self.done, forKey: "done")
    }
}

extension Collection where Iterator.Element == CellItem
{
    // Builds the persistence URL. This is a location inside
    // the "Application Support" directory for the App.
    private static func persistencePath() -> URL?
    {
        let url = try? FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true)
        
        return url?.appendingPathComponent("todoitems.bin")
    }
    
    // Write the array to persistence
    func writeToPersistence() throws
    {
        if let url = Self.persistencePath(), let array = self as? NSArray
        {
            let data = NSKeyedArchiver.archivedData(withRootObject: array)
            try data.write(to: url)
        }
        else
        {
            throw NSError(domain: "com.example.MyToDo", code: 10, userInfo: nil)
        }
    }
    
    // Read the array from persistence
    static func readFromPersistence() throws -> [CellItem]
    {
        if let url = persistencePath(), let data = (try Data(contentsOf: url) as Data?)
        {
            if let array = NSKeyedUnarchiver.unarchiveObject(with: data) as? [CellItem]
            {
                return array
            }
            else
            {
                throw NSError(domain: "com.example.MyToDo", code: 11, userInfo: nil)
            }
        }
        else
        {
            throw NSError(domain: "com.example.MyToDo", code: 12, userInfo: nil)
        }
    }
}
