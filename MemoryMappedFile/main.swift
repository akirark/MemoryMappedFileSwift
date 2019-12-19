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
    try mappedFile.open(filePath: "MappedFile", leastSize: 256)
    
    if let buf = mappedFile.mappedBuffer?.bindMemory(to: UInt8.self, capacity: 256) {
        for i in 0 ..< 256 {
            buf[i] = UInt8(i)
        }
        mappedFile.sync()
    }

    mappedFile.close()
    
} catch let error {
    print(error)
}
