//
//  GTStorableHelper.swift
//  GTFileStorable
//
//  Created by Gabriel Theodoropoulos.
//  Copyright © 2019 Gabriel Theodoropoulos. All rights reserved.
//

//    MIT License
//
//    Copyright (c) 2019 Gabriel Theodoropoulos
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//    SOFTWARE.

import Foundation

/**
 This class implements methods that perform the actual work behind
 the `GTStorable` protocol methods.
 
 Note that this class is not public out of its module.
 */
class GTStorableHelper {
    
    // MARK: - Encoding Methods
    
    /**
     It encodes and returns the given object as a JSON object.
     
     By default and if the `customCoders` parameter value is `nil` the settings
     applied to the `JSONEncoder` instance used are:
     
     ```
     encoder.outputFormatting = .prettyPrinted
     encoder.keyEncodingStrategy = .useDefaultKeys
     ```
     
     Use the `customCoders` parameter value to pass a customized JSON encoder and
     override the default one used in the method.
     
     - Parameter object: The object that should be JSON encoded.
     - Parameter customCoders: A `GTStorableToolkit.CustomCoders` optional
     object which can contain a customized JSON encoder.
     - Returns: The JSON encoded object as `Data`.
     - Throws: It propagates the error thrown by the system when encoding fails.
     - Precondition: The source object must conform to `Encodable` (or
     `Codable`) protocol.
     */
    func jsonEncode<T>(object: T, customCoders: GTStorableToolkit.CustomCoders?) throws -> Data? where T: Encodable {
        var encoder: JSONEncoder
        if let customCoders = customCoders, let jsonEncoder = customCoders.jsonEncoder {
            encoder = jsonEncoder
        } else {
            encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            encoder.keyEncodingStrategy = .useDefaultKeys
        }
        
        return try encoder.encode(object)
    }
    
    
    
    /**
     It encodes and returns the given object as a Property List object.
     
     Use the `customCoders` parameter value to pass a customized Property List
     encoder and override the default one used in the method.
     
     - Parameter object: The object that should be encoded as a Property List.
     - Parameter customCoders: A `GTStorableToolkit.CustomCoders` optional
     object which can contain a customized Property List encoder.
     - Returns: The encoded object as `Data`.
     - Throws: It propagates the error thrown by the system when encoding fails.
     - Precondition: The source object must conform to `Encodable` (or
     `Codable`) protocol.
     */
    func plistEncode<T>(object: T, customCoders: GTStorableToolkit.CustomCoders?) throws -> Data? where T: Encodable {
        var encoder: PropertyListEncoder
        if let customCoders = customCoders, let plistEncoder = customCoders.plistEncoder {
            encoder = plistEncoder
        } else {
            encoder = PropertyListEncoder()
        }
        
        return try encoder.encode(object)
    }
    
    
    /**
     It encodes and returns the data of the given object  using the `NSKeyedArchiver` class.
     
     Archiving takes place using the `NSKeyedArchiver` class and the
     `encodeEncodable(_:forKey:)` method.
     
     - Parameter object: The object to archive.
     - Returns: The encoded data.
     - Throws: It propagates the error thrown by the system when encoding fails.
     - Precondition: The source object must conform to `Encodable` (or
     `Codable`) protocol.
     */
    func archive<T>(object: T) throws -> Data? where T: Encodable {
        let archiver = NSKeyedArchiver(requiringSecureCoding: true)
        try archiver.encodeEncodable(object, forKey: NSKeyedArchiveRootObjectKey)
        return archiver.encodedData
    }
    
    
    
    // MARK: - Decoding Methods
    
    /**
     It decodes the given JSON encoded data to the given type, using optionally a
     customized JSON decoder.
     
     If the `customCoders` parameter value is `nil` the setting applied to the JSON decoder
     instance used in the method is:
     
     ```
     decoder.keyDecodingStrategy = .useDefaultKeys
     ```
     
     Use the `customCoders` parameter value to pass a customized JSON decoder and override
     the default one used in the method.
     
     - Parameter data: The data to decode.
     - Parameter type: The custom type to decode to.
     - Parameter customCoders: A `GTStorableToolkit.CustomCoders` optional
     object which can contain a customized JSON decoder.
     - Returns: An instance of the given type with the decoded data.
     - Throws: It propagates the error thrown by the system when decoding fails.
     - Precondition: The source object must conform to `Decodable` (or
     `Codable`) protocol.
     */
    func jsonDecode<T>(using data: Data, objectType type: T.Type, customCoders: GTStorableToolkit.CustomCoders?) throws -> T? where T: Decodable {
        var decoder: JSONDecoder
        if let customCoders = customCoders, let jsonDecoder = customCoders.jsonDecoder {
            decoder = jsonDecoder
        } else {
            decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .useDefaultKeys
        }
        
        return try decoder.decode(type.self, from: data)
    }
    
    
    /**
     It decodes the given Property List encoded data to the given type, using optionally
     a customized Property List decoder.
     
     Use the `customCoders` parameter value to pass a customized Property List decoder
     and override the default one used in the method.
     
     - Parameter data: The data to decode.
     - Parameter type: The custom type to decode to.
     - Parameter customCoders: A `GTStorableToolkit.CustomCoders` optional
     object which can contain a customized Property List decoder.
     - Returns: An instance of the given type with the decoded data.
     - Throws: It propagates the error thrown by the system when decoding fails.
     - Precondition: The source object must conform to `Decodable` (or
     `Codable`) protocol.
     */
    func plistDecode<T>(using data: Data, objectType type: T.Type, customCoders: GTStorableToolkit.CustomCoders?) throws -> T? where T: Decodable {
        var decoder: PropertyListDecoder
        if let customCoders = customCoders, let plistDecoder = customCoders.plistDecoder {
            decoder = plistDecoder
        } else {
            decoder = PropertyListDecoder()
        }
        
        return try decoder.decode(type.self, from: data)
    }
    
    
    /**
     It decodes previously encoded data by the `NSKeyedArchiver` class to the given type.
     
     Decoding is achieved using the `NSKeyedUnarchiver` class and the `decodeDecodable(_:forKey)`
     method.
     
     - Parameter data: The data to decode.
     - Parameter type: The custom type to decode to.
     - Returns: An instance of the given type with the decoded data.
     - Throws: It propagates the error thrown by the system when unarchiving fails.
     - Precondition: The source object must conform to `Decodable` (or
     `Codable`) protocol.
     */
    func unarchive<T>(using data: Data, objectType type: T.Type) throws -> T? where T: Decodable {
        do {
            let unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)
            return unarchiver.decodeDecodable(type.self, forKey: NSKeyedArchiveRootObjectKey)
        } catch {
            throw error
        }
    }
    
    
    
    
    // MARK: - General Methods
    
    /**
     It builds and returns the URL to the file specified by the provided object type
     and the custom storage options.
     
     The `objectType` is used by default as the file name of the file. The extension
     is determined based on the file type (json, plist, etc). Also,
     if `storeOptions` is `nil` then the *documents directory* is the target directory
     by default.
     
     If `storeOptions` is not nil and custom values for a subdirectory, file name or extension
     have been provided, then they are used instead of the default values.
     
     In case the target directory does not exist then it's automatically created if
     the `createSubDir` flag has been set to `true` in the `storeOptions`.
     
     - Parameter storeOptions: A `GTStorableToolkit.StoreOptions` object which holds additional
     information regarding the the file the returned URL regards.
     - Parameter fileType: The type of the file as a `GTStorableToolkit.FileType` value.
     - Parameter objectType: The type of the object the URL composition regards.
     - Returns: The full path to the file as a URL.
     - Throws: It propagates the system error regarding the directory creation operation.
     */
    func getURL<T>(usingOptions storeOptions: GTStorableToolkit.StoreOptions?, for fileType: GTStorableToolkit.FileType, objectType: T.Type) throws -> URL? {
        // Build the directory path and the full path.
        // If the storeOptions parameter is not nil then get the directory
        // value specified there. Otherwise use the documents directory
        // by default.
        var directoryPath = storeOptions?.directory.url() ?? GTStorableToolkit.Directory.documents.url()
        
        // Append any subdirectory if it was given.
        if let options = storeOptions, let subDirectory = options.subDirectory {
            directoryPath.appendPathComponent(subDirectory)
        }
        
        
        // Check if the directory path exists or not.
        // If it doesn't then create it if it was specified so in the storeOptions.
        var isDirectory: ObjCBool = true
        if !FileManager.default.fileExists(atPath: directoryPath.path, isDirectory: &isDirectory) {
            if let options = storeOptions {
                if options.createSubDir {
                    try FileManager.default.createDirectory(at: directoryPath, withIntermediateDirectories: true, attributes: nil)
                }
            }
        }
        
        
        // Build the full path.
        // Determine if a custom file name or self type should be used.
        // Also determine if the default file extension should be used or not.
        var fileName = "\(objectType.self)"
        var fileExtension = fileType.fileExtension()
        
        if let options = storeOptions {
            if let customFileName = options.customFilename { fileName = customFileName }
            if let customExtension = options.customExtension { fileExtension = customExtension }
        }
        
        let fullPath = directoryPath.appendingPathComponent(fileName).appendingPathExtension(fileExtension)
        
        // Return the full path.
        return fullPath
    }
    
    
    /**
     It checks whether the file at the given URL exists or not.
     
     - Parameter url: The URL to the file.
     - Returns: `true` if the file exists, `false` if not.
     */
    func fileExists(at url: URL?) -> Bool {
        guard let url = url else { return false }
        return FileManager.default.fileExists(atPath: url.path)
    }
    
    
    /**
     It removes the file at the given URL.
     
     - Parameter url: The URL to the file that should be removed.
     - Returns: `true` on success, `false` if the `url` is `nil` or the
     files does not exist.
     - Throws: The error thrown by the system when removing a file fails.
     */
    func removeFile(at url: URL?) throws -> Bool {
        guard let url = url, fileExists(at: url) else { return false }
        do {
            try FileManager.default.removeItem(at: url)
            return true
        } catch { throw error }
    }
    
    
    /**
     It creates a backup of the file at the given URL.
     
     The extension *".bak"* is added to the given URL.
     
     - Parameter url: The URL to the file which should be backed up.
     - Returns: `true` on success, `false` if the `url` is `nil` or the source file
     does not exist.
     - Throws: The error thrown by the system when a file copy operation
     fails.
     */
    func backupFile(at url: URL?) throws -> Bool {
        guard let url = url, fileExists(at: url) else { return false }
        do {
            let backupURL = url.appendingPathExtension("bak")
            try FileManager.default.copyItem(at: url, to: backupURL)
            return true
        } catch { throw error }
    }
    
    
    /**
     It writes the given data to a file at the specified URL.
     
     - Parameter data: The original data that should be written to file.
     - Parameter url: The target URL.
     - Returns: `true` on success, `false` if `data` or `url` is `nil`.
     - Throws: The error thrown by the system if writing to file fails.
     */
    func write(data: Data?, to url: URL?) throws -> Bool {
        guard let data = data, let url = url else { return false }
        do {
            try data.write(to: url)
            return true
        } catch { throw error }
    }
    
    
    /**
     It loads and returns data from file contents at the specified URL.
     
     - Parameter url: The URL where the file to load contents from exists.
     - Returns: The file contents as Data or `nil` if the given URL is `nil`
     of the file doesn't exist.
     - Throws: It propagates the data loading thrown error by the system.
     */
    func loadData(from url: URL?) throws -> Data? {
        guard let url = url, fileExists(at: url) else { return nil }
        return try Data(contentsOf: url)
    }
}
