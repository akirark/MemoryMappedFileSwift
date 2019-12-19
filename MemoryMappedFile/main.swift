//
//  main.swift
//  MemoryMappedFile
//
//  Created by Akira Hayashi on 2019/12/19.
//  Copyright © 2019 Akira Hayashi. All rights reserved.
//

import Foundation

var mappedFile = MemoryMappedFile()
var fileSize1 = 0
var fileSize2 = 0

let fileManager = FileManager()

do {
    // Write test data.
    try mappedFile.open(filePath: "MappedFile", leastSize: 256)
    
    if let buf = mappedFile.mappedBuffer?.bindMemory(to: UInt8.self, capacity: 256) {
        for i in 0 ..< 256 {
            buf[i] = UInt8(i)
        }
        mappedFile.sync()
    }
    
    var attr = try fileManager.attributesOfItem(atPath: "MappedFile")
    fileSize1 = (attr[.size] as? Int)!
    
    // Read the test data.
    if let buf = mappedFile.mappedBuffer?.bindMemory(to: UInt8.self, capacity: 256) {
        for i in 0 ..< 256 {
            let str = String(format: "%02X", buf[i])
            print(str, separator: "", terminator: "")
            
            if ((i + 1) % 4) == 0 {
                print(" ", separator: "", terminator: "")
            }
            
            if ((i + 1) % 16) == 0 {
                print()
            }
        }
    }
    
    // Extend the file
    try mappedFile.extend(to: 8192)
    attr = try fileManager.attributesOfItem(atPath: "MappedFile")
    fileSize2 = (attr[.size] as? Int)!
    
    // The contents of the file is kept.
    print("--- Exteneded ----")
    if let buf = mappedFile.mappedBuffer?.bindMemory(to: UInt8.self, capacity: 256) {
        for i in 0 ..< 256 {
            let str = String(format: "%02X", buf[i])
            print(str, separator: "", terminator: "")
            
            if ((i + 1) % 4) == 0 {
                print(" ", separator: "", terminator: "")
            }
            
            if ((i + 1) % 16) == 0 {
                print()
            }
        }
    }
    
    print("FileSize: \(fileSize1) -> \(fileSize2)")
    
    mappedFile.close()
    
} catch let error {
    print(error)
}
