//
//  main.swift
//  MemoryMappedFile
//
//  Created by Akira Hayashi on 2019/12/19.
//  Copyright © 2019 Akira Hayashi. All rights reserved.
//

import Foundation

var mappedFile = MemoryMappedFile()

do {
    // Write test data.
    try mappedFile.open(filePath: "MappedFile", leastSize: 256)
    
    if let buf = mappedFile.mappedBuffer?.bindMemory(to: UInt8.self, capacity: 256) {
        for i in 0 ..< 256 {
            buf[i] = UInt8(i)
        }
        mappedFile.sync()
    }
    
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
    

    mappedFile.close()
    
} catch let error {
    print(error)
}
