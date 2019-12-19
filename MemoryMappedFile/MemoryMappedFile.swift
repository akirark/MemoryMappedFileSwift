//
// Copyright (c) 2019 RK Kaihatsu. All rights reserved.
// Licensed under the MIT license. See LICENSE.txt.
//

import Foundation

struct MemoryMappedFile {

    var filePath: String? = nil
    var fileDescriptor: Int32 = 0
    var mappedSize: Int = 0
    var pageSize: Int = 0
    var mappedBuffer: UnsafeMutableRawPointer? = nil

    enum MemoryMappedFileError : Error {
        case openFileError
    }

    /// Open or create the memory mapped file.
    ///
    /// - Parameters:
    ///   - filePath:   The file path of the memory mapped file.
    ///   - leastSize:  The needed size.
    /// - Throws: `MemoryMappedFileError.openFileError` Error on opening file.
    mutating func open(filePath: String, leastSize: Int) throws {
        var pathBuf = [Int8]()
        pathBuf.append(contentsOf: filePath.utf8CString)

        self.fileDescriptor = Darwin.open(pathBuf, O_CREAT | O_RDWR, S_IREAD | S_IWRITE);
        if self.fileDescriptor == 0 {
            throw MemoryMappedFileError.openFileError
        }
        
        self.pageSize = Int(getpagesize())
        self.mappedSize = ((leastSize + pageSize - 1) / pageSize) * pageSize

        if ftruncate(self.fileDescriptor, off_t(self.mappedSize)) != 0 {
            throw MemoryMappedFileError.openFileError
        }

        self.mappedBuffer = Darwin.mmap(UnsafeMutableRawPointer(mutating: nil),
                self.mappedSize, PROT_READ | PROT_WRITE, MAP_SHARED, self.fileDescriptor, 0)
    }

    /// Close the memory mapped file.
    mutating func close() {
        if let buf = self.mappedBuffer {
            Darwin.munmap(buf, self.mappedSize)
            self.mappedBuffer = nil
            self.mappedSize = 0
        }

        if self.fileDescriptor != 0 {
            Darwin.close(self.fileDescriptor)
            self.fileDescriptor = 0
        }
    }

    /// Synchronize the mapped file with the buffer.
    func sync() {
        guard let buf = self.mappedBuffer else {
            return
        }
        Darwin.msync(buf, self.mappedSize, 0)
    }
    
    /// Extend the mapped file
    ///
    /// - Parameters:
    ///   - newSize:    The needed size.
    /// - Throws: `MemoryMappedFileError.openFileError` Error on opening file.
    mutating func extend(to newSize: Int) throws {
        guard newSize > self.mappedSize else {
            return
        }
        
        if let buf = self.mappedBuffer {
            Darwin.munmap(buf, self.mappedSize)
            self.mappedBuffer = nil
            self.mappedSize = 0
        }
        
        self.mappedSize = ((newSize + pageSize - 1) / pageSize) * pageSize
        
        if ftruncate(self.fileDescriptor, off_t(self.mappedSize)) != 0 {
            throw MemoryMappedFileError.openFileError
        }
        
        self.mappedBuffer = Darwin.mmap(UnsafeMutableRawPointer(mutating: nil),
                                        self.mappedSize, PROT_READ | PROT_WRITE, MAP_SHARED, self.fileDescriptor, 0)        
    }
}
